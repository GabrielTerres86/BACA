/***********************************************************************
 Fonte: aturat.js                                                  
 Autor: Andrei - RKAM
 Data : Maio/2016                Última Alteração: 22/06/2016
                                                                   
 Objetivo  : Cadastro de servicos ofertados na tela ATURAT
                                                                   	 
 Alterações: 22/06/2016 - Ajustado maxlength do campo nrdconta
                          (Andrei - RKAM).
						  
						  
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

            formataFormularioFiltro();

            return false;

        }
    });

    //Define ação para CLICK no botão de OK
    $("#btnOK", "#frmCab").unbind('click').bind('click', function () {

        // Se esta desabilitado o campo 
        if ($("#cddopcao", "#frmCab").prop("disabled") == true) {
            return false;
        }

        formataFormularioFiltro();

        $(this).unbind('click');

        return false;
    });

    //Define ação para CLICK no botão de Concluir
    $("#btConcluir", "#divBotoes").unbind('click').bind('click', function () {

        controlaConcluir();

        return false;

    });

    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoes").unbind('click').bind('click', function () {

        controlaVoltar('1');

        return false;

    });

    //Define ação para CLICK no botão de Prosseguir
    $("#btProsseguir", "#divBotoes").unbind('click').bind('click', function () {

        showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'verificaRatingAtivo();', 'formataFormularioFiltro();', 'sim.gif', 'nao.gif');
        
        return false;

    });

    layoutPadrao();

    return false;
}

function formataFormularioFiltro() {
	
    // Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();

    //Limpa formulario
    $('input[type="text"]', '#frmFiltro').limpaFormulario().removeClass('campoErro');

    //rotulo
    $('label[for="nrdconta"]', "#frmFiltro").addClass("rotulo").css({ "width": "70px" });
    $('label[for="cdagenci"]', "#frmFiltro").addClass("rotulo-linha").css({ "width": "35px" });
    $('label[for="dtinirat"]', "#frmFiltro").addClass("rotulo-linha").css({ "width": "45px" });
    $('label[for="dtfinrat"]', "#frmFiltro").addClass("rotulo-linha").css({ "width": "15px" });
    $('label[for="tprelato"]', "#frmFiltro").addClass("rotulo").css({ "width": "70px" });
    $('label[for="inrisctl"]', "#frmFiltro").addClass("rotulo").css({ "width": "140px" });
   
    // campo
    $("#nrdconta", "#frmFiltro").css({ 'width': '100px', 'text-align': 'right' }).addClass('conta').attr('maxlength', '12').habilitaCampo();
    $('#cdagenci', '#frmFiltro').addClass('pesquisa codigo').css({ 'width': '50px', 'text-align': 'right' }).attr('maxlength', '4').habilitaCampo();
    $('#dtinirat', '#frmFiltro').css({ 'width': '100px', 'text-align': 'right' }).habilitaCampo().addClass('data');
    $('#dtfinrat', '#frmFiltro').css({ 'width': '100px', 'text-align': 'right' }).habilitaCampo().addClass('data');
    $('#tprelato', '#frmFiltro').css({ 'width': '230px' }).habilitaCampo();
    $('#inrisctl', '#frmFiltro').css({ 'width': '45px', 'text-align': 'right' }).desabilitaCampo();

   	$('#frmFiltro').css({ 'display': 'block' });
   	$('#divBotoes').css({ 'display': 'block' });
   	$('#divRiscoCooperado').css('display', 'none');
   	$('#fsetRisco','#frmFiltro').css('display', 'none');
   	$('#btConcluir', '#divBotoes').css({ 'display': 'inline' });
   	$('#btProsseguir', '#divBotoes').css({ 'display': 'none' });
   	$('#btVoltar', '#divBotoes').css({ 'display': 'inline' });
    highlightObjFocus($('#frmFiltro'));

    //Define ação para o campo tprelato
    $("#tprelato", "#frmFiltro").unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');
        
        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

           $("#nrdconta", "#frmFiltro").focus();           

        }

    });

    //Define ação para o campo nrdconta
    $("#nrdconta", "#frmFiltro").unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            if ($('#cddopcao', '#frmCab').val() == 'L') {

                $("#btProsseguir", "#divBotoes").click();
                
                return false;

            } else {
                $("#cdagenci", "#frmFiltro").focus();
            }

        }

    });

    //Define ação para o campo cdagenci
    $("#cdagenci", "#frmFiltro").unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#dtinirat", "#frmFiltro").focus();

        }

    });

    //Define ação para o campo dtinirat
    $("#dtinirat", "#frmFiltro").unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#dtfinrat", "#frmFiltro").focus();

        }

    });

    //Define ação para o campo dtfinrat
    $("#dtfinrat", "#frmFiltro").unbind('keypress').bind('keypress', function (e) {

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#btConcluir", "#divBotoes").click();

            return false;
        }
        

    });
    
    if ($('#cddopcao', '#frmCab').val() == 'R') {
        
        $('#divFiltroRel').css('display', 'block');
        $('#tprelato', '#frmFiltro').focus();
        
    } else {
        
        $('#divFiltroRel').css('display', 'none');
        $("#nrdconta", "#frmFiltro").focus();

    }

    if ($('#cddopcao', '#frmCab').val() == 'L') {
        
        $('#btProsseguir', '#divBotoes').css({ 'display': 'inline' });
        $('#btConcluir', '#divBotoes').css({ 'display': 'none' });
        $('#cdagenci', '#frmFiltro').desabilitaCampo();
        $('#dtinirat', '#frmFiltro').desabilitaCampo();
        $('#dtfinrat', '#frmFiltro').desabilitaCampo();
        $('#tprelato', '#frmFiltro').desabilitaCampo();

    }

    layoutPadrao();

}
	

function formataDetalhes() {

    //Limpa formulario
    $('input[type="text"]', '#frmDetalhes').limpaFormulario().removeClass('campoErro');

    //rotulo
    $('label[for="inrisctl"]', "#frmDetalhes").addClass("rotulo").css({ "width": "100px" });
    $('label[for="nrnotatl"]', "#frmDetalhes").addClass("rotulo-linha").css({ "width": "110px" });
    $('label[for="indrisco"]', "#frmDetalhes").addClass("rotulo-linha").css({ "width": "50px" });
    $('label[for="nrnotrat"]', "#frmDetalhes").addClass("rotulo-linha").css({ "width": "50px" });
    $('label[for="dteftrat"]', "#frmDetalhes").addClass("rotulo").css({ "width": "100px" });
    $('label[for="nmoperad"]', "#frmDetalhes").addClass("rotulo-linha").css({ "width": "70px" });
    $('label[for="vlutlrat"]', "#frmDetalhes").addClass("rotulo").css({ "width": "100px" });

    // campo
    $("#inrisctl", "#frmDetalhes").css({ 'width': '60px', 'text-align': 'right' }).desabilitaCampo();
    $('#nrnotatl', '#frmDetalhes').css({ 'width': '50px', 'text-align': 'right' }).desabilitaCampo();
    $('#indrisco', '#frmDetalhes').css({ 'width': '50px', 'text-align': 'right' }).desabilitaCampo();
    $('#nrnotrat', '#frmDetalhes').css({ 'width': '86px', 'text-align': 'right' }).desabilitaCampo();
    $('#dteftrat', '#frmDetalhes').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();
    $('#nmoperad', '#frmDetalhes').css({ 'width': '300px' }).desabilitaCampo();
    $('#vlutlrat', '#frmDetalhes').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();

    $('#frmDetalhes').css({ 'display': 'block' });
       
    layoutPadrao();

    return false;

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

function controlaVoltar(tipo) {
    
    switch (tipo) {

        case '1':
            
            estadoInicial();

        break;

        case '2':

            $('#divTabela').html('').css('display', 'none');
            formataFormularioFiltro();

        break;

        case '3':

            formataFormularioFiltro();

        break;

    }

    return false;

}


function buscaRatings(nriniseq,nrregist) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var nrdconta = normalizaNumero($('#nrdconta', '#frmFiltro').val());
    var cdagenci = $("#cdagenci", "#frmFiltro").val();    
    var dtinirat = $("#dtinirat", "#frmFiltro").val();
    var dtfinrat = $("#dtfinrat", "#frmFiltro").val();
    var tprelato = $("#tprelato", "#frmFiltro").val();
    var cddopcao = $("#cddopcao", "#frmCab").val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando ratings ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/aturat/busca_ratings.php",
        data: {
            nrdconta: nrdconta,
            cdagenci: cdagenci,            
            dtinirat: dtinirat,
            dtfinrat: dtfinrat,
            cddopcao: cddopcao,
            tprelato: tprelato,
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


function buscaRatingSingular(nrdconta, nrctrrat, tpctrrat, insitrat, dsdopera, indrisco, nrnotrat, nriniseq, nrregist) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando ratings ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/aturat/busca_rating_singular.php",
        data: {
            nrdconta: normalizaNumero(nrdconta),
            nrctrrat: normalizaNumero(nrctrrat),            
            cddopcao: cddopcao,
            tpctrrat: tpctrrat,
            nriniseq: nriniseq,
            nrregist: nrregist,
            insitrat: insitrat,
            dsdopera: dsdopera,
            indrisco: indrisco,
            nrnotrat: normalizaNumero(nrnotrat),
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


function verificaRatingAtivo() {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var nrdconta = normalizaNumero($('#nrdconta', '#frmFiltro').val());
    var cddopcao = $("#cddopcao", "#frmCab").val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, verificando ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/aturat/verifica_rating_ativo.php",
        data: {
            nrdconta: nrdconta,            
            cddopcao: cddopcao,           
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


function verificaAtualizacao(nrdconta, nrctrrat, tpctrrat, insitrat, tpdaoper, dsdopera,indrisco, nrnotrat) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, verificando ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/aturat/verifica_atualizacao.php",
        data: {
            nrdconta: normalizaNumero(nrdconta),
            cddopcao: cddopcao,
            nrctrrat: normalizaNumero(nrctrrat),
            tpctrrat: tpctrrat,
            insitrat: insitrat,
            tpdaoper: tpdaoper,
            dsdopera: dsdopera,
            indrisco: indrisco,
            nrnotrat: nrnotrat,
            rating  : rating,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$(\'#btVoltar\',\'#divBotoesRatings\').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$(\'#btVoltar\',\'#divBotoesRatings\').focus();");
            }

        }

    });

    return false;

}


function calcula(insitrat, rowidnrc, nrdconta, nrctrrat, tpctrrat, dsdopera, indrisco, nrnotrat) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $("#cddopcao", "#frmCab").val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, verificando ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/aturat/calcula.php",
        data: {
            insitrat: insitrat,
            cddopcao: cddopcao,
            rowidnrc: rowidnrc,
            nrdconta: normalizaNumero(nrdconta),
            nrctrrat: normalizaNumero(nrctrrat),
            tpctrrat: tpctrrat,
            indrisco: indrisco,
            nrnotrat: nrnotrat,
            dsdopera: dsdopera,
            rating  : rating,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "");
            }

        }

    });

    return false;

}


function atualizaRiscoCooperado(flgatltl) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var nrdconta = normalizaNumero($('#nrdconta', '#frmFiltro').val());
    var cddopcao = $("#cddopcao", "#frmCab").val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, atualizando risco ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/aturat/atualiza_risco_cooperado.php",
        data: {
            nrdconta: nrdconta,
            cddopcao: cddopcao,
            flgatltl: flgatltl,
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


function formataTabelaRatings() {

    var divRegistro = $('div.divRegistros', '#divTabela');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '250px' });
    $('#divRegistrosRodape', '#divTabela').formataRodapePesquisa();

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '50px';
    arrayLargura[1] = '90px';
    arrayLargura[2] = '75px';
    arrayLargura[3] = '130px';
    arrayLargura[4] = '90px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'left';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    $('table > tbody > tr', divRegistro).each(function (i) {

        if ($(this).hasClass('corSelecao')) {

            selecionaRating($(this));

        }

    });

    //seleciona o lancamento que é clicado
    $('table > tbody > tr', divRegistro).click(function () {

        selecionaRating($(this));
    });

    return false;

}


function formataTabelaRatingSingular() {

    var divRegistro = $('div.divRegistros');
    var tabela = $('table', divRegistro);

    divRegistro.css({ 'height': '250px', 'border-bottom': '1px dotted #777', 'padding-bottom': '2px' });

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '370px';
    arrayLargura[2] = '50px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);


    $('table > tbody > tr', divRegistro).each(function (i) {

        var elemento = $(this);

        $('#flgativo', $(this)).unbind('click').bind('click', function () {

            ativaRating($(elemento));

        });

        if ($(this).hasClass('corSelecao')) {

            selecionaRatingSingular($(this));

        }

    });

    //seleciona o lancamento que é clicado
    $('table > tbody > tr', divRegistro).click(function () {

        selecionaRatingSingular($(this));
    });

    return false;
}


function formataFormularioRatingSingular() {

    // rotulo
    $('label[for="vlrdnota"]', "#divDados").addClass("rotulo").css({ "width": "80px" });
    $('label[for="nivrisco"]', "#divDados").addClass("rotulo").css({ "width": "80px" });
    $('label[for="datatual"]', "#divDados").addClass("rotulo-linha").css({ "width": "65px" });
    $('label[for="nrtopico"]', "#divRatings").addClass("rotulo").css({ "width": "80px" });
    $('label[for="nritetop"]', "#divRatings").addClass("rotulo").css({ "width": "80px" });

    // campo
    $("#vlrdnota", "#divDados").css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();
    $('#nivrisco', '#divDados').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();
    $('#datatual', '#divDados').css("width", "120px").desabilitaCampo();
    $("#nrtopico", "#divRatings").css({ 'width': '80px', 'text-align': 'left' }).desabilitaCampo();
    $('#nritetop', '#divRatings').css({ 'width': '80px', 'text-align': 'left' }).desabilitaCampo();
    $('#dstopico', '#divRatings').css({ 'width': '400px', 'text-align': 'left' }).desabilitaCampo();
    $('#dsseqite', '#divRatings').css({ 'width': '400px', 'text-align': 'left' }).desabilitaCampo();

    layoutPadrao();

    return false;

}

function ativaRating(tr) {

    ($('#flgativo', tr).prop('checked')) ? rating[$(tr).attr('id')]["selecionado"] = 1 : rating[$(tr).attr('id')]["selecionado"] = 0;

    return false;

}

function atualizaSelecionado2() {

    var divRegistro = $('div.divRegistros');

    $('table > tbody > tr', divRegistro).each(function (i) {

        if (!$(this).hasClass('pulaLinha')) {

            ($('#flgativo', $(this)).prop('checked')) ? rating[$($(this)).attr('id')]["selecionado"] = 1 : rating[$($(this)).attr('id')]["selecionado"] = 0;

        }

    });

    return false;

}


function selecionaRatingSingular(tr) {

    if (!$(tr).hasClass('pulaLinha')) {

        $('#nrtopico', '#divRatings').val($('#topico', tr).val());
        $('#nritetop', '#divRatings').val($('#itetop', tr).val());
        $('#dstopico', '#divRatings').val($('#dsc_topico', tr).val());
        $('#dsseqite', '#divRatings').val($('#dsc_itetop', tr).val());

    }

    return false;

}

function selecionaRating(tr) {

    $('#nrnotatl','#fsetDetalhes').val($('#nrnotatl',tr).val());
    $('#inrisctl','#fsetDetalhes').val($('#inrisctl',tr).val());
    $('#indrisco','#fsetDetalhes').val($('#indrisco',tr).val());
    $('#nrnotrat','#fsetDetalhes').val($('#nrnotrat',tr).val());
    $('#dteftrat','#fsetDetalhes').val($('#dteftrat',tr).val());
    $('#nmoperad','#fsetDetalhes').val($('#nmoperad',tr).val());
    $('#vlutlrat', '#fsetDetalhes').val($('#vlutlrat', tr).val());
    
    if ($('#cddopcao', '#frmCab').val() == 'R') {


        //Define ação para CLICK no botão de btImprimir
        $("#btImprimir", "#divBotoesRatings").unbind('click').bind('click', function () {

            if ($('#nrctrrat', tr).val() == 0 && $('#tpctrrat', tr).val() == 0) {

                geraRelatorioRisco($('#nrdconta', tr).val());

            } else {

                geraRating($('#nrdconta', tr).val(), $('#nrctrrat', tr).val(), $('#tpctrrat', tr).val());
            }


            return false;

        });

    }else if($('#cddopcao', '#frmCab').val() == 'A') {
        
        //Define ação para CLICK no botão de btImprimir
        $("#BtConcluir", "#divBotoesRatings").unbind('click').bind('click', function () {

            verificaAtualizacao($('#nrdconta', tr).val(), $('#nrctrrat', tr).val(), $('#tpctrrat', tr).val(), $('#insitrat', tr).val(), '0', $('#dsdopera', tr).val(), $('#indrisco', tr).val(), $('#nrnotrat', tr).val());

            return false;

        });

    }
        
    return false;

}


function geraRelatorioRisco(nrdconta) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cddopcao', '#frmCab').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/aturat/gera_relatorio.php',
        data: {
            nrdconta: normalizaNumero(nrdconta),
            cddopcao: cddopcao,
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#btVoltar','#divBotoesRatings').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();$("#btVoltar","#divBotoesRatings").focus();');
            }

        }
    });

    return false;

}


function geraRating(nrdconta, nrctrrat, tpctrrat) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cddopcao', '#frmCab').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    //Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, solicitando relatório...');

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: 'POST',
        url: UrlSite + 'telas/aturat/gera_rating.php',
        data: {
            nrdconta: normalizaNumero(nrdconta),
            cddopcao: cddopcao,
            nrctrrat: normalizaNumero(nrctrrat),
            tpctrrat: normalizaNumero(tpctrrat),
            redirect: 'html_ajax' // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$(\'#btVoltar\',\'#divBotoesRatings\').focus();");
        },
        success: function (response) {
            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'unblockBackground();$(\'#btVoltar\',\'#divBotoesRatings\').focus();');
            }

        }
    });

    return false;

}

function controlaConcluir() {  

    if ($('#cddopcao', '#frmCab').val() == 'R' ||
        $('#cddopcao', '#frmCab').val() == 'A' ||
        $('#cddopcao', '#frmCab').val() == 'C') {
        
        showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', ' buscaRatings(1,30)', '$("#btVoltar","#divBotoes").focus()', 'sim.gif', 'nao.gif');
                               
    //Opcao L
    }else{
        
        showConfirmacao('Deseja atualizar o Risco Cooperado?', 'Confirma&ccedil;&atilde;o - Ayllos', 'atualizaRiscoCooperado("0");', 'formataFormularioFiltro();', 'sim.gif', 'nao.gif');

    }    

}


function controlaConcluirSingular(nrdconta, nrctrrat, tpctrrat, insitrat, dsdopera, indrisco, nrnotrat) {

    var divRegistro = $('div.divRegistros');

    $('table > tbody > tr', divRegistro).each(function (i) {

        if (!$(this).hasClass('pulaLinha')) {

            ($('#flgativo', $(this)).prop('checked')) ? rating[$($(this)).attr('id')]["selecionado"] = 1 : rating[$($(this)).attr('id')]["selecionado"] = 0;

        }

    });

    verificaAtualizacao(nrdconta, nrctrrat, tpctrrat, insitrat, '1', dsdopera, indrisco, nrnotrat);

    
    return false;

}


function formataTabela () {

	var divRegistro = $('div.divRegistros', '#tabAturat');		
	var tabela      = $('table', divRegistro );
	var linha       = $('table > tbody > tr', divRegistro );
	
	$('#tabAturat').css({'margin-top':'5px'});
	divRegistro.css({'height':'100px', 'padding-bottom':'2px'});

	var ordemInicial = new Array();

	var arrayLargura = new Array();
	arrayLargura[0] = '10%';
	arrayLargura[1] = '14%';
	arrayLargura[2] = '15%';
	arrayLargura[3] = '29%';
	arrayLargura[4] = '15%';
	arrayLargura[5] = '15%';

	var arrayAlinha = new Array();
	arrayAlinha[0] = 'center';
	arrayAlinha[1] = 'left';
	arrayAlinha[2] = 'right';
	arrayAlinha[3] = 'center';
	arrayAlinha[4] = 'center';
	arrayAlinha[5] = 'center';
	
	tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

	return false;
	
}

// Função para envio de formulário de impressao
function Gera_Impressao(nmarqpdf, callback) {

    hideMsgAguardo();

    var action = UrlSite + 'telas/aturat/imprimir_pdf.php';

    $('#nmarqpdf', '#frmCab').remove();
	$('#sidlogin', '#frmCab').remove();

	$('#frmCab').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');
	$('#frmCab').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + $('#sidlogin', '#frmMenu').val() + '" />');

	carregaImpressaoAyllos("frmCab", action, callback);

}




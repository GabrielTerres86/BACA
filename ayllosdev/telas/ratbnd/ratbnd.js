/*!
 * FONTE        : ratbnd.js
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 22/11/2013
 * OBJETIVO     : Biblioteca de funções da tela RATBND
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

// Definição de Variaveis Globais
var cddopcao	= 'C';
var nometela;
var inpessoa;
var nrcpfcgc;
var nome;
var agencia;
var tpctrato;

// Variaveis Auxiliares
var aux_inconfir = 2;
var aux_retorno  = '';
var txtGrupoEco  = '';
var txtCriticas  = '';
var aux_nrctrato = '';

//Formulários e Tabela
var frmCab   		= 'frmCab';
var frmConta   	    = 'frmConta';
var frmContrato   	= 'frmContrato';
var frmNome   		= 'frmNome';
var frmDetalhe      = 'frmDetalhe';
var frmSituacao     = 'frmSituacao';
var frmImpressao   	= 'frmImpressao';
var frmRelRatingOpe = 'frmRelRatingOpe';

var nrdconta, tipopesq, nmprimtl, nrctrato, vlempbnd, qtparbnd, nrinfcad, nrgarope, nrliquid, dspatlvr, nrperger,
    dtiniper, dtfimper, cdoperad, tpctrato,

    cTodosCabecalho, cTodosConta, cTodosContrato, cTodosDetalhes,

    btnOK,  btnOkConta, btnOkContrato, btnOkImpressao;

var rCddopcao, rNrdconta, rNrctarel, rNmprimtl, rNomtitul, rNrctrato, rNrinfcad, rVlempbnd, rQtparbnd, rNrgarope,
    rNrliquid, rNrpatlvr, rNrperger, rDtiniper, rDtfimper, rDssitcrt, rCdtiprel, rDtiniper, rDtfimper, rCdagenci,
    rNvctrato,

    cCddopcao, cNrdconta, cNrctarel, cNmprimtl, cNomtitul, cNrctrato, cNrinfcad, cVlempbnd, cQtparbnd, cNrgarope,
    cNrliquid, cNrpatrim, cNrperger, cDtiniper, cDtfimper, cDspatrim, cDsinfcad, cDsgarope, cDsliquid, cDsperger,
    cDssitcrt, cCdtiprel, cDtiniper, cDtfimper, cCdagenci, cNvctrato;

var lupas;



function setaDatasTela() {

    var dtHoje  = new Date();
    dtIniPer 	=  dataString("01/" + (dtHoje.getMonth() + 1)  + "/" + dtHoje.getFullYear());
    dtFimPer 	=  dataString(buscaDia(dtHoje.getDate()) + "/" + (dtHoje.getMonth() + 1) + "/" + dtHoje.getFullYear());

    $('#dtiniper','#frmRelRatingOpe').val(dtIniPer);
    $('#dtfimper','#frmRelRatingOpe').val(dtFimPer);

    return false;
}


// Configura data na Tela
function dataString(vData) {

    var dtArray = vData.split('/');

    switch (dtArray[1]) {
    case "1":
    case "2":
    case "3":
    case "4":
    case "5":
    case "6":
    case "7":
    case "8":
    case "9":
        vMes = "0" + (dtArray[1]);
        break;
    default:
        vMes = dtArray[1];
    }

    return dtArray[0] + "/" + vMes + "/" + dtArray[2];
}


function buscaDia(vDia){

    // Concatena o 1 a 9 com 0 na frente
    if (vDia < 10) {vDia = "0" + vDia}

    return vDia;
}



// Inicio
$(document).ready(function() {

    highlightObjFocus( $('#'+frmCab) );
    estadoInicial();

    return false;
});



function estadoInicial() {

    // Limpar conteúdo HTML
    $('#divContrato').html("");
    $('#divDetalhe').html("");
    $('#divResultado').html("");
    $('#divSituacao').html("");


    // Estilo de Visualização
    $('#divConta').css('display','none');
    $('#'+frmConta).css('display','none');
    $('#divContrato').css('display','none');
    $('#'+frmContrato).css('display','none');
    $('#tabRatbnd').css('display','none');
    $('#'+frmNome).css('display','none');
    $('#divDetalhe').css('display','none');
    $('#'+frmDetalhe).css('display','none');
    $('#divResultado').css('display','none');
    $('#divSituacao').css('display','none');
    $('#'+frmSituacao).css('display','none');
    $('#'+frmImpressao).css('display','none');
    $('#'+frmRelRatingOpe).css('display','none');
    $('#divTela').fadeTo(0,0.1);


    highlightObjFocus( $('#'+frmConta) );
    highlightObjFocus( $('#'+frmImpressao) );


    formataCabecalho();
    cTodosConta.limpaFormulario();
    removeOpacidade('divTela');
    unblockBackground();


    // Configura Botoes
    $('#divBotoes').css({'display':'block'});
    trocaBotao('Prosseguir','btnContinuar();');
    $('#btVoltar','#divBotoes').hide();


    // Configura Campos
    $('#cddopcao','#'+frmCab).habilitaCampo();
    $('#nrdconta','#'+frmConta).habilitaCampo();
    $('#nrctrato','#frmContrato').habilitaCampo();
    $('#nmprimtl','#'+frmConta).desabilitaCampo();
    cTodosConta.removeClass('campoErro');


    // Inicializa Campo
    cCddopcao.val("C");
    cCdtiprel.val("S");
    cCddopcao.focus();
    txtGrupoEco = '';
    txtCriticas = '';
    aux_inconfir    = 2;


    controlaFoco();
    return false;
}


function estadoImpressao() {

    highlightObjFocus( $('#frmRelRatingOpe') );


    if (cCdtiprel.val() == "S") { // Sem Rating Proposto

        $('#divConta').css('display','none');
        $('#frmConta').css('display','none');
        $('#frmRelRatingOpe').css('display','block');
        $('#tabRelConta').css('display','none');
        formataRelRatingOpe();

		// Controle de bloqueio/liberação
        cCdtiprel.desabilitaCampo();
        cNrctarel.habilitaCampo();
        cCdagenci.habilitaCampo();
        cDtiniper.habilitaCampo();
        cDtfimper.habilitaCampo();
        cNomtitul.desabilitaCampo();


		// Inicializa variaveis
        cNrctarel.val(0);
        cNomtitul.val("");
        cCdagenci.val(0);
		cCdagenci.focus();
        setaDatasTela();

        trocaBotao('Imprimir','geraImpressao();');
        controlaFocoImpressao();

    }else
    if (cCdtiprel.val() == "R") { // Operacoes BNDES

		$('#divConta').css('display','none');
        $('#frmConta').css('display','none');
        $('#frmRelRatingOpe').css('display','block');
        $('#tabRelConta').css('display','block');
        formataRelRatingOpe();


		// Controle de bloqueio/liberação
        cCdtiprel.desabilitaCampo();
        cNrctarel.habilitaCampo();
        cCdagenci.desabilitaCampo();
        cDtiniper.desabilitaCampo();
        cDtfimper.desabilitaCampo();
        cNomtitul.desabilitaCampo();


		// Inicializa variaveis
        cNrctarel.val(0);
        cNomtitul.val("");
        cCdagenci.val(0);
        cNrctarel.focus();
        setaDatasTela();

        trocaBotao('Prosseguir','btnContinuar();');
        controlaFocoImpressao();

    }

    return false;
}



// Formatação de Cabeçalhos
function formataCabecalho() {

    // Rotulo - Cabecalho
    rCddopcao			= $('label[for="cddopcao"]','#'+frmCab);

    // Campo - Cabecalho
    cCddopcao			= $('#cddopcao','#'+frmCab);
    cTodosCabecalho		= $('input[type="text"],select','#'+frmCab);
    btnOK				= $('#btnOK','#'+frmCab);

	btnOK.removeAttr('disabled');

    rCddopcao.addClass('rotulo').css({'width':'64px'});

    cCddopcao.css({'width':'490px'});



    // Rotulo - Conta
    rNrdconta = $('label[for="nrdconta"]','#'+frmConta);
    rNmprimtl = $('label[for="nmprimtl"]','#'+frmConta);

	// Campo - Conta
    cNrdconta   = $('#nrdconta','#'+frmConta);
    cNmprimtl 	= $('#nmprimtl','#'+frmConta);
    cTodosConta	= $('input[type="text"],select','#'+frmConta);
    btnOkConta	= $('#btnOkConta','#'+frmConta);

	btnOkConta.removeAttr('disabled');

    rNrdconta.addClass('rotulo').css({'margin-left':'2px','width':'56px'});
    rNmprimtl.addClass('rotulo-linha').css({'width':'45px'});

    cNrdconta.addClass('conta').css({'width':'70px'});
    cNmprimtl.css({'width':'369px'});



    // Rotulo - Impressao
    rCdtiprel = $('label[for="cdtiprel"]','#'+frmImpressao);

    // Campo - Impressao
    cCdtiprel      = $('#cdtiprel','#'+frmImpressao);
    btnOkImpressao = $('#btnOkImpressao','#'+frmImpressao);

	// Remove Atributo que desabilita os Botões OK
	btnOkImpressao.removeAttr('disabled');

    rCdtiprel.addClass('rotulo').css({'width':'58px'});

    cCdtiprel.css({'width':'492px'});


    layoutPadrao();
    return false;
}


function formataContrato() {

	// Rotulo - Contrato
    rNrctrato = $('label[for="nrctrato"]','#frmContrato');
    rVlempbnd = $('label[for="vlempbnd"]','#frmContrato');
    rQtparbnd = $('label[for="qtparbnd"]','#frmContrato');


    // Campo - Cabecalho
    cNrctrato = $('#nrctrato','#frmContrato');
    cVlempbnd = $('#vlempbnd','#frmContrato');
    cQtparbnd = $('#qtparbnd','#frmContrato');
    cTodosContrato	= $('input[type="text"],select','#frmContrato');
    btnOkContrato   = $('#btnOkContrato','#'+frmContrato);

	// Remove atributo de bloqueio do botão
	btnOkContrato.removeAttr('disabled');

    rNrctrato.addClass('rotulo-linha').css({'width':'60px'});
    rVlempbnd.addClass('rotulo-linha').css({'width':'80px'});
    rQtparbnd.addClass('rotulo-linha').css({'width':'126px'});


    cNrctrato.css({'width':'100px'});
    cVlempbnd.css({'width':'100px','text-align':'right'});
    cQtparbnd.css({'width': '42px','text-align':'right'});


	layoutPadrao();
    return false;
}


function formataDetalhe() {

    // Rotulo - Detalhe
    rNrinfcad = $('label[for="nrinfcad"]','#frmDetalhe');
    rNrgarope = $('label[for="nrgarope"]','#frmDetalhe');
    rNrliquid = $('label[for="nrliquid"]','#frmDetalhe');
    rNrpatrim = $('label[for="nrpatlvr"]','#frmDetalhe');
    rNrperger = $('label[for="nrperger"]','#frmDetalhe');
    rDssitcrt = $('label[for="dssitcrt"]','#frmSituacao');
    rNvctrato = $('label[for="nvctrato"]','#frmSituacao');


    // Campo - Cabecalho
    cNrinfcad = $('#nrinfcad','#frmDetalhe');
    cDsinfcad = $('#dsinfcad','#frmDetalhe');
    cNrgarope = $('#nrgarope','#frmDetalhe');
    cDsgarope = $('#dsgarope','#frmDetalhe');
    cNrliquid = $('#nrliquid','#frmDetalhe');
    cDsliquid = $('#dsliquid','#frmDetalhe');
    cNrpatrim = $('#nrpatlvr','#frmDetalhe');
    cDspatrim = $('#dspatlvr','#frmDetalhe');
    cNrperger = $('#nrperger','#frmDetalhe');
    cDsperger = $('#dsperger','#frmDetalhe');
    cDssitcrt = $('#dssitcrt','#frmSituacao');
    cNvctrato = $('#nvctrato','#frmSituacao');
    cTodosDetalhes	= $('input[type="text"],select','#frmDetalhe');


    rNrinfcad.addClass('rotulo').css({'width':'150px'});
    rNrgarope.addClass('rotulo').css({'width':'150px'});
    rNrliquid.addClass('rotulo').css({'width':'150px'});
    rNrpatrim.addClass('rotulo').css({'width':'250px'});
    rNrperger.addClass('rotulo').css({'width':'250px'});
    rDssitcrt.addClass('rotulo').css({'width':'100px'});
    rNvctrato.addClass('rotulo-linha').css({'width':'100px'});


    cNrinfcad.css({'width':'20px'});
    cDsinfcad.css({'width':'395px'});
    cNrgarope.css({'width':'20px'});
    cDsgarope.css({'width':'395px'});
    cNrliquid.css({'width':'20px'});
    cDsliquid.css({'width':'395px'});
    cNrpatrim.css({'width':'20px'});
    cDspatrim.css({'width':'295px'});
    cNrperger.css({'width':'20px'});
    cDsperger.css({'width':'295px'});
    cDssitcrt.css({'width':'140px'});
    cNvctrato.css({'width':'140px'});



	// Controle de Bloqueio/Liberacao
    if ( (cCddopcao.val() == "C")  ||  // Consulta
         (cCddopcao.val() == "E") ) {  // Efetivar

		cNrinfcad.desabilitaCampo();
        cNrgarope.desabilitaCampo();
        cNrliquid.desabilitaCampo();
        cNrpatrim.desabilitaCampo();
        cNrperger.desabilitaCampo();

    }else
    if (cCddopcao.val() == "I") { // Incluir

        cNrinfcad.habilitaCampo();
        cNrgarope.habilitaCampo();
        cNrliquid.habilitaCampo();
        cNrpatrim.habilitaCampo();
        cNrperger.habilitaCampo();

    }else
    if (cCddopcao.val() == "A") { // Alterar

        cNrinfcad.habilitaCampo();
        cNrgarope.habilitaCampo();
        cNrliquid.habilitaCampo();
        cNrpatrim.habilitaCampo();
        cNrperger.habilitaCampo();

    }


    cDsinfcad.desabilitaCampo();
    cDsgarope.desabilitaCampo();
    cDsliquid.desabilitaCampo();
    cDspatrim.desabilitaCampo();
    cDsperger.desabilitaCampo();
    cDssitcrt.desabilitaCampo();
    cNvctrato.desabilitaCampo();


	layoutPadrao();
    return false;
}


function formataRelRatingOpe() {

    // Rotulo - Cabecalho
    rNrctarel			= $('label[for="nrdctarl"]','#frmRelRatingOpe');
    rNomtitul			= $('label[for="nmtitul"]','#frmRelRatingOpe');
    rCdagenci			= $('label[for="cdagenci"]','#frmRelRatingOpe');
    rDtiniper			= $('label[for="dtiniper"]','#frmRelRatingOpe');
    rDtfimper			= $('label[for="dtfimper"]','#frmRelRatingOpe');


    // Campo - Cabecalho
    cNrctarel			= $('#nrdctarl','#frmRelRatingOpe');
    cNomtitul			= $('#nmtitul','#frmRelRatingOpe');
    cCdagenci			= $('#cdagenci','#frmRelRatingOpe');
    cDtiniper			= $('#dtiniper','#frmRelRatingOpe');
    cDtfimper			= $('#dtfimper','#frmRelRatingOpe');
    cTodosRelSemRating	= $('input[type="text"],select','#frmRelRatingOpe');


    rNrctarel.addClass('rotulo').css({'margin-left':'2px','width':'56px'});
    rNomtitul.addClass('rotulo-linha').css({'width':'50px'});
    rCdagenci.addClass('rotulo').css({'width':'58px'});
    rDtiniper.addClass('rotulo-linha').css({'width':'80px'});
    rDtfimper.addClass('rotulo-linha').css({'width':'25px'});

    cNrctarel.addClass('conta').css({'width':'70px'});
    cNomtitul.css({'width':'369px'});
    cCdagenci.css({'width':'40px'});
    cDtiniper.addClass('data').css({'width':'90px'});
    cDtfimper.addClass('data').css({'width':'90px'});


	layoutPadrao();
    return false;
}



// Controle de Foco da Tela - EstadoInicial
function controlaFoco() {

    cCddopcao.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            btnOK.click();

			return false;
        }
    });


    btnOK.unbind('click').bind('click', function() {


		// Atributo que desabilita os Botões OK
		btnOK.attr('disabled', 'disabled');


		$('#btVoltar','#divBotoes').show();


        if ( divError.css('display') == 'block' ) { return false; }


        cTodosConta.removeClass('campoErro');
        cCddopcao.desabilitaCampo();


        if ( (cCddopcao.val() == "C")   || // Consulta
             (cCddopcao.val() == "E")   || // Efetivar
             (cCddopcao.val() == "A") )  { // Alterar

            $('#'+frmConta).css('display','block');

            cNrdconta.focus();
            cNmprimtl.desabilitaCampo();

        }else
        if (cCddopcao.val() == "R") { // Relatório

            cCdtiprel.habilitaCampo();

            trocaBotao('Prosseguir','estadoImpressao();');
            $('#'+frmImpressao).css('display','block');

            cCdtiprel.focus();

        }else
        if ( cCddopcao.val() == "I" ){ // Incluir

            $('#'+frmConta).css('display','block');

            cNrdconta.focus();
            cNmprimtl.desabilitaCampo();

        }

        return false;
    });


    btnOK.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {


			$('#btVoltar','#divBotoes').show();


            if ( divError.css('display') == 'block' ) { return false; }


            cTodosConta.removeClass('campoErro');
            cCddopcao.desabilitaCampo();


            if ( (cCddopcao.val() == "C")   || // Consulta
                 (cCddopcao.val() == "E")   || // Efetivar
                 (cCddopcao.val() == "A") )  { // Alterar

                $('#'+frmConta).css('display','block');

                cNrdconta.focus();
                cNmprimtl.desabilitaCampo();

            }else
            if (cCddopcao.val() == "R") { // Relatório

                cCdtiprel.habilitaCampo();

                trocaBotao('Prosseguir','estadoImpressao();');
                $('#'+frmImpressao).css('display','block');

                cCdtiprel.focus();

            }else
            if ( cCddopcao.val() == "I" ){ // Incluir

                $('#'+frmConta).css('display','block');

                cNrdconta.focus();
                cNmprimtl.desabilitaCampo();

            }

            return false;
        }
    });


    cNrdconta.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            btnOkConta.click();

			return false;
        }
    });


    btnOkConta.unbind('click').bind('click', function() {


		// Atributo que desabilita os Botões OK
		btnOkConta.attr('disabled', 'disabled');


        if ( divError.css('display') == 'block' ) { return false; }


        if ( (cCddopcao.val() == "C")   || // Consulta
             (cCddopcao.val() == "E")   || // Efetivar
             (cCddopcao.val() == "A") )  { // Alterar

			cTodosConta.removeClass('campoErro');
            trocaBotao('Prosseguir','btnConsultaRating();');

            cNrdconta.desabilitaCampo();
            consultarConta();

            $('#divResultado').css('display','block');

        }else
        if ( cCddopcao.val() == "I" ){ // Incluir

            cTodosConta.removeClass('campoErro');

			cNrdconta.desabilitaCampo();
            consultarConta();

            $('#divResultado').css('display','block');
        }

        return false;
    });


    btnOkConta.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {


            if ( divError.css('display') == 'block' ) { return false; }


            if ( (cCddopcao.val() == "C")   || // Consulta
                 (cCddopcao.val() == "E")   || // Efetivar
                 (cCddopcao.val() == "A") )  { // Alterar

                trocaBotao('Prosseguir','btnConsultaRating();');
                cTodosConta.removeClass('campoErro');

                cNrdconta.desabilitaCampo();
                consultarConta();

                $('#divResultado').css('display','block');

            }else
            if ( cCddopcao.val() == "I" ){ // Incluir

                cTodosConta.removeClass('campoErro');

				cNrdconta.desabilitaCampo();
                consultarConta();

                $('#divResultado').css('display','block');

            }

            return false;
        }
    });


    cCdtiprel.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            btnOkImpressao.click();

			return false;
        }
    });


    btnOkImpressao.unbind('click').bind('click', function() {

        if ( divError.css('display') == 'block' ) { return false; }

		// Atributo que desabilita os Botões OK
		btnOkImpressao.attr('disabled','disabled');

        cCdtiprel.desabilitaCampo();
        estadoImpressao();

        return false;
    });


    btnOkImpressao.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            if ( divError.css('display') == 'block' ) { return false; }

            cCdtiprel.desabilitaCampo();
            estadoImpressao();

            return false;
        }
    });

    return false;
}


function controlaFocoContrato() {

    cNrctrato.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

			// Atributo que desabilita os Botões OK
			btnOkContrato.attr('disabled', 'disabled');

            btnConsultaRating();

            return false;
        }
    });


    btnOkContrato.unbind('click').bind('click', function() {

		// Atributo que desabilita os Botões OK
		btnOkContrato.attr('disabled', 'disabled');

        btnConsultaRating();

        return false;
    });


    btnOkContrato.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

			// Atributo que desabilita os Botões OK
			btnOkContrato.attr('disabled', 'disabled');

            btnConsultaRating();

            return false;
        }
    });

    return false;
}


function controlaFocoInclusao() {


	// Atributo que desabilita os Botões OK
	btnOkContrato.attr('disabled', 'disabled');


    cVlempbnd.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            cQtparbnd.focus();

            return false;
        }
    });


    cQtparbnd.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            cNrinfcad.focus();

            return false;
        }
    });


    cNrinfcad.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            cNrgarope.focus();

            return false;
        }
    });


    cNrgarope.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            cNrliquid.focus();

            return false;
        }
    });


    cNrliquid.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            cNrpatrim.focus();

            return false;
        }
    });


    cNrpatrim.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            if (inpessoa == 1) {

                validaCampoRatbnd();

            } else {

                cNrperger.focus();

            }

            return false;
        }
    });


    cNrperger.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            bo			= 'b1wgen0059.p';
            procedure = 'busca_seqrating';
            titulo      = 'Patrim&ocirc;nio Livre';
            nrtopico    = '3';
            nritetop    = '11';
            filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop+';flgcompl|no;nrseqite|'+$(this).val();
            buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsperger',$(this).val(),'dsseqit1',filtrosDesc,'frmDetalhe');
            validaCampoRatbnd();

            return false;
        }
    });


    cNrinfcad.unbind('change').bind('change',function() {

        bo			= 'b1wgen0059.p';
        procedure   = 'busca_seqrating';
        titulo      = 'Informa&ccedil;&atilde;o Cadastral';
        nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
        nritetop    = ( inpessoa == 1 ) ? '4' : '3';
        filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop+';flgcompl|no;nrseqite|'+$(this).val();
        buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsinfcad',$(this).val(),'dsseqit1',filtrosDesc,'frmDetalhe');

        return false;
    });


    cNrgarope.unbind('change').bind('change',function() {

        bo			= 'b1wgen0059.p';
        procedure   = 'busca_seqrating';
        titulo      = 'Garantia';
        nrtopico    = ( inpessoa == 1 ) ? '2' : '4';
        nritetop    = ( inpessoa == 1 ) ? '2' : '2';
        filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop+';flgcompl|no;nrseqite|'+$(this).val();
        buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsgarope',$(this).val(),'dsseqit1',filtrosDesc,'frmDetalhe');

        return false;
    });


    cNrliquid.unbind('change').bind('change',function() {

        bo			= 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo      = 'Liquidez';
        nrtopico    = ( inpessoa == 1 ) ? '2' : '4';
        nritetop    = ( inpessoa == 1 ) ? '3' : '2';
        filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop+';flgcompl|no;nrseqite|'+$(this).val();
        buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsliquid',$(this).val(),'dsseqit1',filtrosDesc,'frmDetalhe');

        return false;
    });


    cNrpatrim.unbind('change').bind('change',function() {

        if (inpessoa == 1) {

            bo			= 'b1wgen0059.p';
            procedure = 'busca_seqrating';
            titulo      = 'Patrim&ocirc;nio Livre';
            nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
            nritetop    = ( inpessoa == 1 ) ? '8' : '9';
            filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop+';flgcompl|no;nrseqite|'+$(this).val();
            buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dspatlvr',$(this).val(),'dsseqit1',filtrosDesc,'frmDetalhe');

        } else {

            bo			= 'b1wgen0059.p';
            procedure = 'busca_seqrating';
            titulo      = 'Patrim&ocirc;nio Livre';
            nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
            nritetop    = ( inpessoa == 1 ) ? '8' : '9';
            filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop+';flgcompl|no;nrseqite|'+$(this).val();
            buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dspatlvr',$(this).val(),'dsseqit1',filtrosDesc,'frmDetalhe');

        }

        return false;
    });


    cNrperger.unbind('change').bind('change',function() {

        bo			= 'b1wgen0059.p';
        procedure = 'busca_seqrating';
        titulo      = 'Patrim&ocirc;nio Livre';
        nrtopico    = '3';
        nritetop    = '11';
        filtrosDesc = 'nrtopico|'+nrtopico+';nritetop|'+nritetop+';flgcompl|no;nrseqite|'+$(this).val();
        buscaDescricao(bo,procedure,titulo,$(this).attr('name'),'dsperger',$(this).val(),'dsseqit1',filtrosDesc,'frmDetalhe');

        return false;
    });

    return false;
}


function controlaFocoImpressao() {

    cNrctarel.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            if (cCdtiprel.val() == "R") { // Operacoes BNDES

                cNrctarel.desabilitaCampo();
                btnContinuar();

            }else {

                cNrctarel.desabilitaCampo();
                cCdagenci.focus();

            }

            return false;
        }
    });


    cCdagenci.unbind('keypress').bind('keypress',function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            cDtiniper.focus();

            return false;
        }
    });


    cDtiniper.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            cDtfimper.focus();

            return false;
        }
    });


    cDtfimper.unbind('keypress').bind('keypress', function(e) {
        if ( e.keyCode == 9 || e.keyCode == 13 ) {

            geraImpressao();

            return false;
        }
    });

    return false;
}



// Controle de Botoes
function trocaBotao( botao , funcao ) {

    $('#divBotoes').html('');
    $('#divBotoes').append('<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;" >Voltar</a>&nbsp;');

    if (botao != '') {
        $('#divBotoes').append('<a href="#" class="botao" id="btSalvar" onclick=' + funcao + ' return false;" >' + botao + '</a>');
    }

    return false;
}



// Botoes
function btnVoltar() {

	// Remove o Atributo que deabilita os Botões OK
	btnOK.removeAttr('disabled');
	btnOkConta.removeAttr('disabled');

    estadoInicial();

    return false;
}


function btnVoltar2() {

    $('#divRelatorioEfetivo').css({'display':'none'});
    fechaRotina($('#divRotina'));

    return false;
}


function btnContinuar() {

    $('#btVoltar','#divBotoes').show();


    if ( divError.css('display') == 'block' ) { return false; }


    if ( cCddopcao.hasClass('campo') ) {

        btnOK.click();

    }else
    if ( (cCddopcao.val() == "C")   || // Consulta
         (cCddopcao.val() == "E")   || // Efetivar
         (cCddopcao.val() == "A") )  { // Alterar

		cTodosConta.removeClass('campoErro');
        trocaBotao('Prosseguir','btnConsultaRating();');

        cNrdconta.desabilitaCampo();
        consultarConta();

        $('#divResultado').css('display','block');

    }else
    if ( cCddopcao.val() == "I" ){ // Incluir

        cTodosConta.removeClass('campoErro');

        cNrdconta.desabilitaCampo();
        consultarConta();

        $('#divResultado').css('display','block');

    }else
    if ( cCddopcao.val() == "R" ){ // Relatorio

        cTodosConta.removeClass('campoErro');

        consultarConta();
    }

    return false;
}


function btnConsultaRating() {

    if ( divError.css('display') == 'block' ) { return false; }

    highlightObjFocus( $('#frmContrato') );
    highlightObjFocus( $('#frmDetalhe') );

    cNrctrato.desabilitaCampo();
    consultaRating();

    return false;
}


function btnConfirmEfetivar(){

    showConfirmacao('078 - Confirma efetiva&ccedil;&atilde;o proposta BNDES? (S/N)',"Confirma&ccedil;&atilde;o - Ayllos",'efetivarRegistro();','estadoInicial();',"sim.gif","nao.gif");

    return false;
}


function btnImprimirRatEfetivo(){

    var nrdconta1 = nrdconta;
    var nrctrato1 = nrctrato;
    var tpctrato1 = tpctrato;
    var cdoperad1 = cdoperad;


    showMsgAguardo('Aguarde, imprimindo rating...');


    $('#nrdconta', '#frmImprimir').val( nrdconta1 );
    $('#tpctrato', '#frmImprimir').val( tpctrato1 );
    $('#nrctrato', '#frmImprimir').val( nrctrato1 );
    $('#cdoperad', '#frmImprimir').val( cdoperad1 );

	var action = UrlSite + 'telas/'+nometela+'/relatorio_ratbnd_efetivo.php';
	var callafter = "blockBackground(parseInt($('#divRotina').css('z-index')));";
    carregaImpressaoAyllos("frmImprimir",action,callafter);

    return false;
}



// Requisições
function consultarConta() {

	/********************************
	Função para Consultar o Associado
	********************************/

	// Atributo que desabilita os Botões OK
	btnOkConta.attr('disabled', 'disabled');


	// Carrega variavel de acordo com a opcao
    if ( (cCddopcao.val() == "C")   || // Consulta
         (cCddopcao.val() == "E")   || // Efetivar
         (cCddopcao.val() == "A") )  { // Alterar

        var nrdconta = cNrdconta.val();
        nrdconta = nrdconta.replace(/[-. ]*/g,'');
        var cddopcao = cCddopcao.val();
        var tipopesq = cCddopcao.val();

    }else
    if ( cCddopcao.val() == "I" ){ // Incluir

        var nrdconta = cNrdconta.val();
        nrdconta = nrdconta.replace(/[-. ]*/g,'');
        var cddopcao = cCddopcao.val();
        var tipopesq = cCddopcao.val();

    }else
    if ( cCddopcao.val() == "R" ){ // Relatório

        var nrdconta = cNrctarel.val();
        nrdconta = nrdconta.replace(/[-. ]*/g,'');
        var cddopcao = cCddopcao.val();
        var tipopesq = cCddopcao.val();

    }


	showMsgAguardo('Aguarde, buscando informacoes...');


    $.ajax({
        type	: 'POST',
        dataType: 'html',
        url		: UrlSite + 'telas/'+nometela+'/consulta_conta.php',
        data    :
                { cddopcao	: cddopcao,
                  nrdconta  : nrdconta,
                  tipopesq  : tipopesq,
                  redirect: 'script_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                },
        success : function(response) {
			hideMsgAguardo();

			if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
				try {
					cNrdconta.removeClass('campoErro');

					$('#divResultado').html(response);

					if ( (cCddopcao.val() == "C")   || // Consulta
						 (cCddopcao.val() == "E") )  { // Efetivar

						$('#divContrato').css('display','block');
						$('#frmContrato').css('display','block');
						formataContrato();

						cNmprimtl.val($('#nmprimtl','#'+frmNome).val());
						inpessoa = $('#inpessoa','#'+frmNome).val();
						nrcpfcgc = $('#nrcpfcgc','#'+frmNome).val();

						trocaBotao('Prosseguir','btnConsultaRating();');

						cVlempbnd.desabilitaCampo();
						cQtparbnd.desabilitaCampo();

						cNrctrato.focus();
						controlaFocoContrato();
					}else
					if ( cCddopcao.val() == "I" ){ // Incluir

						$('#divContrato').css('display','block');
						$('#frmContrato').css('display','block');
						formataContrato();

						cNmprimtl.val($('#nmprimtl','#'+frmNome).val());
						inpessoa = $('#inpessoa','#'+frmNome).val();
						nrcpfcgc = $('#nrcpfcgc','#'+frmNome).val();

						highlightObjFocus( $('#frmContrato') );
						highlightObjFocus( $('#frmDetalhe') );

						$('#divDetalhe').css('display','block');
						$('#frmDetalhe').css('display','block');
						formataDetalhe();

						cNrctrato.desabilitaCampo();
						cVlempbnd.habilitaCampo();
						cVlempbnd.addClass('moeda');
						cQtparbnd.habilitaCampo();

						controlaFocoInclusao();
						controlaPesquisas();
						trocaBotao('Incluir','validaCampoRatbnd();');

						layoutPadrao();
						cVlempbnd.focus();

					}else
					if ( cCddopcao.val() == "A" ){ // Alterar

						$('#divContrato').css('display','block');
						$('#frmContrato').css('display','block');
						formataContrato();

						cNmprimtl.val($('#nmprimtl','#'+frmNome).val());
						inpessoa = $('#inpessoa','#'+frmNome).val();
						nrcpfcgc = $('#nrcpfcgc','#'+frmNome).val();

						trocaBotao('Prosseguir','btnConsultaRating();');

						cVlempbnd.desabilitaCampo();
						cQtparbnd.desabilitaCampo();

						layoutPadrao();
						cNrctrato.focus();
						controlaFocoContrato();

					}else
					if ( cCddopcao.val() == "R" ){ // Incluir

						$('#divConta').css('display','none');
						$('#frmConta').css('display','none');
						$('#divDetalhe').css('display','none');
						$('#frmDetalhe').css('display','none');

						if (nome != "" || agencia != 0) {

							cNomtitul.val(nome);
							cCdagenci.val(agencia);

							cDtiniper.habilitaCampo();
							cDtfimper.habilitaCampo();

							cDtiniper.focus();
							controlaFocoImpressao();

							cNrctarel.removeClass('campoErro');
							trocaBotao('Prosseguir','geraImpressao();');

						} else {

							cCdagenci.habilitaCampo();
							cDtiniper.habilitaCampo();
							cDtfimper.habilitaCampo();

							cCdagenci.focus();
							controlaFocoImpressao();
							cNrctarel.removeClass('campoErro');
							trocaBotao('Prosseguir','geraImpressao();');

						}
					}

					hideMsgAguardo();

				} catch(error) {
					hideMsgAguardo();
					showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
				}
			} else {
					try {
						hideMsgAguardo();

						if ( (cCddopcao.val() == "C")   || // Consulta
							 (cCddopcao.val() == "E")   || // Efetivar
							 (cCddopcao.val() == "I" )  || // Incluir
							 (cCddopcao.val() == "A" ) ) { // Alterar

							 // Remove o Atributo que deabilita os Botões OK
							 btnOkConta.removeAttr('disabled');

							cNrdconta.habilitaCampo();
							trocaBotao('Prosseguir','consultarConta();');

						}else
						if ( cCddopcao.val() == "R" ){ // Relatorio

							if (nome != "" || agencia != 0) {

								$('#nrdctarl','#frmRelRatingOpe').habilitaCampo();

							} else {

								cCdagenci.habilitaCampo();

							}
						}

						eval( response );

						return false;
					} catch(error) {
						hideMsgAguardo();
						showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
					}
				}
			}
    });

    return false;
}


function consultaRating() {

	/****************************
	Função que consulta contratos
	do associado
	****************************/


	// Atributo que desabilita os Botões OK
	btnOkContrato.attr('disabled', 'disabled');


    var nrdconta = cNrdconta.val();
    nrdconta = nrdconta.replace(/[-. ]*/g,'');
    var cddopcao = cCddopcao.val();
    var tppesqui = cCddopcao.val();
    inpessoa = inpessoa;
    nrcpfcgc = nrcpfcgc;
    var nrctrato = cNrctrato.val();


    if (inpessoa == 1) {

        showMsgAguardo('Aguarde, consultando contrato...');

    }else {

        showMsgAguardo('Aguarde, consultando rating...');

    }


    $.ajax({
        type	: 'POST',
        dataType: 'html',
        url		: UrlSite + 'telas/'+nometela+'/consulta_rating.php',
        data    :
                { cddopcao	: cddopcao,
                  nrdconta  : nrdconta,
                  tppesqui  : tppesqui,
                  inpessoa  : inpessoa,
                  nrcpfcgc  : nrcpfcgc,
                  nrctrato  : nrctrato,
                  redirect: 'script_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                },
        success : function(response) {
            hideMsgAguardo();
            try {
                $('#divResultados').html(response);
                $('#divResultados').html('');

                if (tpcritic == 0) { // Sucesso

                    $('#divResultados').html(response);

                    cNrdconta.removeClass('campoErro');

                    $('#divDetalhe').css('display','block');
                    $('#frmDetalhe').css('display','block');

                    if ( cCddopcao.val() == "C") { // Consulta

                        $('#btSalvar','#divBotoes').hide();

                        $('#divSituacao').css('display','block');
                        $('#frmSituacao').css('display','block');

                    }else
                    if ( cCddopcao.val() == "E" ){ // Efetivar

                        $('#divSituacao').css('display','none');
                        $('#frmSituacao').css('display','none');

                        $('#btSalvar','#divBotoes').show();

                        trocaBotao('Efetivar','btnConfirmEfetivar();');

                    }else
                    if ( cCddopcao.val() == "A" ){ // Alterar

                        $('#divSituacao').css('display','none');
                        $('#frmSituacao').css('display','none');
                        $('#divDetalhe').css('display','block');
                        $('#frmDetalhe').css('display','block');

                        highlightObjFocus( $('#frmContrato') );
                        highlightObjFocus( $('#frmDetalhe') );

                        formataDetalhe();

                        cVlempbnd.habilitaCampo();
                        cVlempbnd.addClass('moeda');
                        cQtparbnd.habilitaCampo();

                        controlaFocoInclusao();

                        $('#btSalvar','#divBotoes').show();

                        trocaBotao('Alterar','validaCampoRatbnd();');

                        layoutPadrao();
                        cVlempbnd.focus();

                    }

                    formataDetalhe();

                    cVlempbnd.val($('#vlctrbnd','#frmDetalhe').val());
                    cQtparbnd.val($('#qtparbnd','#frmDetalhe').val());
                    cNrinfcad.val($('#nrinfcad','#frmDetalhe').val());
                    cDsinfcad.val($('#dsinfcad','#frmDetalhe').val());
                    cNrgarope.val($('#nrgarope','#frmDetalhe').val());
                    cDsgarope.val($('#dsgarope','#frmDetalhe').val());
                    cNrliquid.val($('#nrliquid','#frmDetalhe').val());
                    cDsliquid.val($('#dsliquid','#frmDetalhe').val());
                    cNrpatrim.val($('#nrpatlvr','#frmDetalhe').val());
                    cDspatrim.val($('#dspatlvr','#frmDetalhe').val());
                    cNrperger.val($('#nrperger','#frmDetalhe').val());
                    cDsperger.val($('#dsperger','#frmDetalhe').val());

                    controlaPesquisas();

                } else {

                    $('#divResultados').css('display','none');
                    $('#divUsoGenerico').html(response);

                }
            } catch(error) {
                hideMsgAguardo();

				// Remove o Atributo que desabilita os Botões OK
				btnOkContrato.removeAttr('disabled');

                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
            }
        }
    });

    return false;
}


function incluirRegistro(){

	/*******************
	Inclusão do Registro
	*******************/

    var cddopcao = cCddopcao.val();
    var nrdconta = cNrdconta.val();
    nrdconta = nrdconta.replace(/[-. ]*/g,'');
    inpessoa = inpessoa;
    nrcpfcgc = nrcpfcgc;
    vlempbnd = cVlempbnd.val();
    qtparbnd = cQtparbnd.val();
    nrinfcad = cNrinfcad.val();
    nrgarope = cNrgarope.val();
    nrliquid = cNrliquid.val();
    nrpatrim = cNrpatrim.val();
    nrperger = cNrperger.val();
    inconfir = 3;
    var nrctrato = aux_nrctrato;


    hideMsgAguardo();


    if (inpessoa == 1) {

        showMsgAguardo('Aguarde, incluindo contrato...');

    }else {

        showMsgAguardo('Aguarde, incluindo rating...');

    }


    $.ajax({
        type	: 'POST',
        dataType: 'html',
        url		: UrlSite + 'telas/'+nometela+'/incluir_rating.php',
        data    :
                { cddopcao	: cddopcao,
                  nrdconta  : nrdconta,
                  inpessoa  : inpessoa,
                  nrcpfcgc  : nrcpfcgc,
                  vlempbnd  : vlempbnd,
                  qtparbnd  : qtparbnd,
                  nrinfcad  : nrinfcad,
                  nrgarope  : nrgarope,
                  nrliquid  : nrliquid,
                  nrpatrim  : nrpatrim,
                  nrperger  : nrperger,
                  inconfir  : inconfir,
                  nrctrato  : nrctrato,
                  redirect: 'html_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                },
        success : function(response) {
            hideMsgAguardo();
            try {

                $('#divSituacao').html(response);

                lupas.addClass('lupa').css('cursor','auto');
				lupas.attr('disabled','disabled');

                $('#btSalvar','#divBotoes').hide();

                formataDetalhe();

				cTodosDetalhes.desabilitaCampo();
				cTodosContrato.desabilitaCampo();

                $('#divSituacao').css('display','block');
                $('#frmSituacao').css('display','block');
                $('#divNumContrato').css('display','block');

				showError('inform','Inclus&atilde;o efetuada com sucesso!','Alerta - Ayllos','');

            } catch(error) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
            }
        }
    });

    return false;
}


function alterarRegistro(){

	/********************
	Alteração do Registro
	********************/

    var cddopcao = cCddopcao.val();
    var nrdconta = cNrdconta.val();
    nrdconta = nrdconta.replace(/[-. ]*/g,'');
    inpessoa = inpessoa;
    nrcpfcgc = nrcpfcgc;
    vlempbnd = cVlempbnd.val();
    qtparbnd = cQtparbnd.val();
    nrinfcad = cNrinfcad.val();
    nrgarope = cNrgarope.val();
    nrliquid = cNrliquid.val();
    nrpatrim = cNrpatrim.val();
    nrperger = cNrperger.val();
    inconfir = 3;
    var nrctrato = cNrctrato.val();


    hideMsgAguardo();


    if (inpessoa == 1) {

        showMsgAguardo('Aguarde, alterando contrato...');

    }else {

        showMsgAguardo('Aguarde, alterando rating...');

    }


    $.ajax({
        type	: 'POST',
        dataType: 'html',
        url		: UrlSite + 'telas/'+nometela+'/alterar_rating.php',
        data    :
                { cddopcao	: cddopcao,
                  nrdconta  : nrdconta,
                  inpessoa  : inpessoa,
                  nrcpfcgc  : nrcpfcgc,
                  vlempbnd  : vlempbnd,
                  qtparbnd  : qtparbnd,
                  nrinfcad  : nrinfcad,
                  nrgarope  : nrgarope,
                  nrliquid  : nrliquid,
                  nrpatrim  : nrpatrim,
                  nrperger  : nrperger,
                  inconfir  : inconfir,
                  nrctrato  : nrctrato,
                  redirect: 'html_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                },
        success : function(response) {
            hideMsgAguardo();
            try {

                $('#divSituacao').html(response);

                lupas.addClass('lupa').css('cursor','auto');
				lupas.attr('disabled','disabled');

                $('#btSalvar','#divBotoes').hide();

				formataDetalhe();

                cTodosContrato.desabilitaCampo();
                cTodosDetalhes.desabilitaCampo();

                $('#divSituacao').css('display','block');
                $('#frmSituacao').css('display','block');
                $('#divNumContrato').css('display','none');

				showError('inform','Altera&ccedil;&atilde;o efetuada com sucesso!','Alerta - Ayllos','');

            } catch(error) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
            }
        }
    });

    return false;
}


function efetivarRegistro() {

	/*********************
	Efetivação do Registro
	*********************/

    cddopcao = cCddopcao.val();
    nrdconta = cNrdconta.val();
    nrdconta = nrdconta.replace(/[-. ]*/g,'');
    tppesqui = cCddopcao.val();
    var nrctrato = $('#nrctrato','#frmContrato').val();
    inpessoa = inpessoa;

    showMsgAguardo('Aguarde, efetivando rating...');

    $.ajax({
        type	: 'POST',
        dataType: 'html',
        url		: UrlSite + 'telas/'+nometela+'/efetivar_ratbnd.php',
        data    :
                { cddopcao	: cddopcao,
                  nrdconta  : nrdconta,
                  tppesqui  : tppesqui,
                  nrctrato  : nrctrato,
                  inpessoa  : inpessoa,
                  redirect: 'html_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina)');
                },
        success : function(response) {
            try {
                try {
                    eval(response);

                    if (tpcritic == 0) {

                        hideMsgAguardo();

                        $('#divSituacao').css('display','block');
                        $('#frmSituacao').css('display','block');

                        $("#dssitcrt","#frmSituacao").val(dssitcrt);

                        $("#btSalvar","#divBotoes").hide();

                        bloqueiaFundo(divRotina);

                        showError('inform','Efetiva&ccedil;&atilde;o efetuada com sucesso!','Alerta - Ayllos','');

                    }
                } catch(error) {  // Exibir mensagens do tipo 830
                    $('#divUsoGenerico').html(response);

                }
            } catch(error) {
                    hideMsgAguardo();
                    showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','bloqueiaFundo(divRotina);');
            }
        }
    });

    return false;
}


function geraImpressao(){

	/*********************************
	Função que imprime os tipos de
	Relatório - Sem Rating Efetivo
             	Rating Operações BNDES
	*********************************/

    cddopcao = cCddopcao.val();
    tprelato = $('#cdtiprel','#frmImpressao').val();
    nrdconta = $('#nrdctarl','#frmRelRatingOpe').val();
    nrdconta = nrdconta.replace(/[-. ]*/g,'');
    cdagenci = cCdagenci.val();
    dtiniper = $('#dtiniper','#frmRelRatingOpe').val();
    dtfimper = $('#dtfimper','#frmRelRatingOpe').val();
    tppesqui = cCddopcao.val();


    if (tprelato == "S") { // Sem Rating Efetivo

		showMsgAguardo('Aguarde, imprimindo rating...');

        $('#nrdconta', '#frmImprimir').val( nrdconta );
        $('#cdagenci', '#frmImprimir').val( cdagenci );
        $('#cddopcao', '#frmImprimir').val( cddopcao );
        $('#dtiniper', '#frmImprimir').val( dtiniper );
        $('#dtfimper', '#frmImprimir').val( dtfimper );
        $('#tppesqui', '#frmImprimir').val( tppesqui );

        var action = UrlSite + 'telas/'+nometela+'/relatorio_ratbnd.php';

        carregaImpressaoAyllos("frmImprimir",action);

    }else
	if (tprelato == "R") { //Rating Operações BNDES

        dadosRatingEfetivo();

    }

    return false;
}


function dadosRatingEfetivo(){

	/***************************
	Função que exibe registro do
	Relatório de Operações BNDES
	***************************/

    showMsgAguardo("Aguarde, abrindo rating...");


    // Executa Script de Confirmação Através de Ajax
    $.ajax({
        type    : 'POST',
        dataType: 'html',
        url     : UrlSite + 'telas/'+nometela+'/frame_relatorio.php',
        data    :
                {
                    redirect: 'html_ajax'
                },
        error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            try {
                if ( response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1 ) {
                    try {
						$('#divRotina').html(response);
						$('#divConta').css('display','none');
						$('#frmConta').css('display','none');

						ContratosBndes();

                    } catch(error) {
                        hideMsgAguardo();

                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                    }
                } else {
                    try {
                        eval(response);

                        return false;
                    } catch(error) {
                        hideMsgAguardo();
                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    }
                }
            } catch(error) {
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
                hideMsgAguardo();
            }
        }
    });

    return false;
}


function ContratosBndes(){

	/***************************
	Função que carrega tela para
	exibição dos registro
	***************************/

	hideMsgAguardo();

	cddopcao = cCddopcao.val();
    tprelato = $('#cdtiprel','#frmImpressao').val();
    nrdconta = cNrctarel.val();
    nrdconta = nrdconta.replace(/[-. ]*/g,'');
    cdagenci = cCdagenci.val();
    dtiniper = cDtiniper.val();
    dtfimper = cDtfimper.val();
    tppesqui = cCddopcao.val();


    showMsgAguardo("Aguarde, buscando dados...");


    $.ajax({
        type	: 'POST',
        dataType: 'html',
        url		: UrlSite + 'telas/'+nometela+'/relatorio_ratbnd.php',
        data    :
                { cddopcao	: cddopcao,
                  nrdconta  : nrdconta,
                  tppesqui  : tppesqui,
                  cdagenci  : cdagenci,
                  dtiniper  : dtiniper,
                  dtfimper  : dtfimper,
                  tprelato  : tprelato,
                  redirect: 'html_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                },
        success : function(response) {
            try {

                if ( response.indexOf('showError("error"') == -1) { // Nao tem erro
                    try {
                        exibeRotina($('#divRotina'));
                        $('#divRelatorioEfetivo').html(response);
                        exibeContratos();

                    } catch(error) {

                        hideMsgAguardo();

                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');

                    }
                } else {
                    try {
                        eval(response);

                        return false;
                    } catch(error) {

                        hideMsgAguardo();

                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');

                    }
                }
            } catch(error) {

                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");

                hideMsgAguardo();

            }
        }
    });

    return false;
}


function exibeContratos() {

	/*****************************
	Função encarregada de ajuste e
	posicionamento da tela
	*****************************/

	highlightObjFocus($('#tabContrato'));

	formataTabContratos();

    $('#divRelatorioEfetivo').css({'width':'500px', 'height':'220px'});

    // centraliza a divRotina
    $('#divRotina').css({'width':'600px'});
    $('#divRelatorioEfetivo').css({'width':'600px'});
    $('#divRotina').centralizaRotinaH();

	blockBackground(parseInt($("#divRotina").css("z-index")));

    return false;
}


function formataTabContratos() {

	/*****************************
	Função encarregada de formatar
	os registros na tela
	*****************************/

    $('#divRelatorioEfetivo').css({'display':'block'});

    var divRegistro = $('div.divRegistros','#tabContrato');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );


    $('#tabContrato').css({'margin-top':'5px'});
    divRegistro.css({'height':'165px','padding-bottom':'2px'});


    var ordemInicial = new Array();


    var arrayLargura = new Array();
    arrayLargura[0] = '70px';
    arrayLargura[1] = '70px';
    arrayLargura[2] = '70px';
    arrayLargura[3] = '70px';
    arrayLargura[4] = '58px';


    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';


    var metodoTabela = '';


    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, metodoTabela );
	hideMsgAguardo();

    /********************
     FORMATA COMPLEMENTO
    *********************/


    // complemento linha 1
    var linha1  = $('ul.complemento', '#linha1').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha1).addClass('txtNormalBold').css({'width':'18%','text-align':'right'});
        $('li:eq(1)', linha1).addClass('txtNormal').css({'width':'5%'});
        $('#inrisctl','.complemento').html( $('#inrisctl').val() );

        $('li:eq(2)', linha1).addClass('txtNormalBold').css({'width':'10%','text-align':'right'});
        $('li:eq(3)', linha1).addClass('txtNormal').css({'width':'15%'});
        $('#nrnotrat','.complemento').html( $('#nrnotrat').val() );

        $('li:eq(4)', linha1).addClass('txtNormalBold').css({'width':'10%','text-align':'right'});
        $('li:eq(5)', linha1).addClass('txtNormal').css({'width':'15%'});
        $('#indrisco','.complemento').html( $('#indrisco').val() );

        $('li:eq(6)', linha1).addClass('txtNormalBold').css({'width':'10%','text-align':'right'});
        $('li:eq(7)', linha1).addClass('txtNormal').css({'width':'15%'});
        $('#nrnotatl','.complemento').html( $('#nrnotatl').val() );


    // complemento linha 2
    var linha2  = $('ul.complemento', '#linha2').css({'margin-left':'1px','width':'99.5%'});

        $('li:eq(0)', linha2).addClass('txtNormalBold').css({'width':'18%','text-align':'right'});
        $('li:eq(1)', linha2).addClass('txtNormal').css({'width':'15%'});
        $('#dteftrat','.complemento').html( $('#dteftrat').val() );

        $('li:eq(2)', linha2).addClass('txtNormalBold').css({'width':'25%','text-align':'right'});
        $('li:eq(3)', linha2).addClass('txtNormal').css({'width':'25%'});
        $('#nmoperad','.complemento').html( $('#nmoperad').val() );


    /********************
    EVENTO COMPLEMENTO
    *********************/


    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click( function() {
        selecionaTabela($(this));
    });


    // seleciona o registro que é focado
    $('table > tbody > tr', divRegistro).focus( function() {
        selecionaTabela($(this));
    });


    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;
}


function selecionaTabela(tr) {

    $('#inrisctl','.complemento').html( $('#inrisctl', tr).val() );
    $('#nrnotrat','.complemento').html( $('#nrnotrat', tr).val() );
    $('#indrisco','.complemento').html( $('#indrisco', tr).val() );
    $('#nrnotatl','.complemento').html( $('#nrnotatl', tr).val() );
    $('#dteftrat','.complemento').html( $('#dteftrat', tr).val() );
    $('#nmoperad','.complemento').html( $('#nmoperad', tr).val() );

    nrdconta = $('#nrdconta', tr).val();
    nrctrato = $('#nrctrato', tr).val();
    cdoperad = $('#cdoperad', tr).val();
    tpctrato = $('#tpctrato', tr).val();

    return false;
}


function controlaPesquisas() {

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var nomeCampo 	  = '';
    var divRotina = 'divTela';
    var bo, procedure, titulo, qtReg, filtros, colunas, varAux, nrtopico, nritetop;


    // Atribui a classe lupa para os links de desabilita todos
    lupas = $('a:not(.lupaFat)','#frmDetalhe');


    if ( cCddopcao.val() == "I" || cCddopcao.val() == "A")  { // Incluir ou Alterar

        lupas.addClass('lupa').css('cursor','pointer');
		lupas.removeAttr('disabled');


        // Percorrendo todos os links
        lupas.each( function() {
            $(this).unbind('click').bind('click', function() {

                // Obtenho o nome do campo anterior
                campoAnterior = $(this).prev().attr('name');

                if ( campoAnterior == 'nrinfcad' ) {

                    bo			= 'b1wgen0059.p';
                    procedure = 'busca_seqrating';
                    titulo      = 'Itens do Rating';
                    qtReg		= '20';
                    nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
                    nritetop    = ( inpessoa == 1 ) ? '4' : '3';
                    filtrosPesq	= 'Cód. Inf. Cadastral;nrinfcad;30px;S;0|Inf. Cadastral;dsinfcad;200px;S;|;nrtopico;;;'+nrtopico+';N|;nritetop;;;'+nritetop+';N|;flgcompl;;;no;N';
                    colunas 	= 'Seq. Item;nrseqite;20%;right|Descrição Seq. Item;dsseqite;80%;left;dsseqit1';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
                    return false;

                }else
				if ( campoAnterior == 'nrgarope' ) {

                    bo			= 'b1wgen0059.p';
                    procedure = 'busca_seqrating';
                    titulo      = 'Itens do Rating';
                    qtReg		= '20';
                    nrtopico    = ( inpessoa == 1 ) ? '2' : '4';
                    nritetop    = ( inpessoa == 1 ) ? '2' : '2';
                    filtrosPesq	= 'Cód. Inf. Cadastral;nrgarope;30px;S;0|Inf. Cadastral;dsgarope;200px;S;|;nrtopico;;;'+nrtopico+';N|;nritetop;;;'+nritetop+';N|;flgcompl;;;no;N';
                    colunas 	= 'Seq. Item;nrseqite;20%;right|Descrição Seq. Item;dsseqite;80%;left;dsseqit1';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
                    return false;

                }else
				if ( campoAnterior == 'nrliquid' ) {

					bo			= 'b1wgen0059.p';
                    procedure = 'busca_seqrating';
                    titulo      = 'Itens do Rating';
                    qtReg		= '20';
                    nrtopico    = ( inpessoa == 1 ) ? '2' : '4';
                    nritetop    = ( inpessoa == 1 ) ? '3' : '3';
                    filtrosPesq	= 'Cód. Inf. Cadastral;nrliquid;30px;S;0|Inf. Cadastral;dsliquid;200px;S;|;nrtopico;;;'+nrtopico+';N|;nritetop;;;'+nritetop+';N|;flgcompl;;;no;N';
                    colunas 	= 'Seq. Item;nrseqite;20%;right|Descrição Seq. Item;dsseqite;80%;left;dsseqit1';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
                    return false;

                }else
				if ( campoAnterior == 'nrpatlvr' ) {

                    bo			= 'b1wgen0059.p';
                    procedure = 'busca_seqrating';
                    titulo      = 'Itens do Rating';
                    qtReg		= '20';
                    nrtopico    = ( inpessoa == 1 ) ? '1' : '3';
                    nritetop    = ( inpessoa == 1 ) ? '8' : '9';
                    filtrosPesq	= 'Cód. Inf. Cadastral;nrpatlvr;30px;S;0|Inf. Cadastral;dspatlvr;200px;S;|;nrtopico;;;'+nrtopico+';N|;nritetop;;;'+nritetop+';N|;flgcompl;;;no;N';
                    colunas 	= 'Seq. Item;nrseqite;20%;right|Descrição Seq. Item;dsseqite;80%;left;dsseqit1';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
                    return false;

                }else
				if ( campoAnterior == 'nrperger' ) {

                    bo			= 'b1wgen0059.p';
                    procedure = 'busca_seqrating';
                    titulo      = 'Itens do Rating';
                    qtReg		= '20';
                    nrtopico    = '3';
                    nritetop    = '11';
                    filtrosPesq	= 'Cód. Inf. Cadastral;nrperger;30px;S;0|Inf. Cadastral;dsperger;200px;S;|;nrtopico;;;'+nrtopico+';N|;nritetop;;;'+nritetop+';N|;flgcompl;;;no;N';
                    colunas 	= 'Seq. Item;nrseqite;20%;right|Descrição Seq. Item;dsseqite;80%;left;dsseqit1';
                    mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,divRotina);
                    return false;

                }
            });
        });
    }

    return false;
}


function validaCampoRatbnd() {

	/***********************************
	Função que valida Campos de	Detalhes
	Inf. Cadastrais    - Garantia
	Liquidez           - Patr. Pessoal
	Patr. Garant/Soci  - Percepção Geral
	***********************************/

    cddopcao = cCddopcao.val();
    nrdconta = cNrdconta.val();
    nrdconta = nrdconta.replace(/[-. ]*/g,'');
    tppesqui = cCddopcao.val();
    inpessoa = inpessoa;
    nrcpfcgc = nrcpfcgc;
    vlempbnd = cVlempbnd.val();
    qtparbnd = cQtparbnd.val();
    nrinfcad = cNrinfcad.val();
    nrgarope = cNrgarope.val();
    nrliquid = cNrliquid.val();
    nrpatlvr = cNrpatrim.val();
    nrperger = cNrperger.val();


    showMsgAguardo('Aguarde, validado itens rating...');


    $.ajax({
        type	: 'POST',
        dataType: 'html',
        url		: UrlSite + 'telas/'+nometela+'/validacao_campos_ratbnd.php',
        data    :
                { cddopcao	: cddopcao,
                  nrdconta  : nrdconta,
                  tppesqui  : tppesqui,
                  inpessoa  : inpessoa,
                  nrcpfcgc  : nrcpfcgc,
                  vlempbnd  : vlempbnd,
                  qtparbnd  : qtparbnd,
                  nrinfcad  : nrinfcad,
                  nrgarope  : nrgarope,
                  nrliquid  : nrliquid,
                  nrpatlvr  : nrpatlvr,
                  nrperger  : nrperger,
                  redirect: 'script_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                },
        success : function(response) {
            try {
                if ( response.indexOf('showError("error"') == -1) {
                    try {
                        cTodosDetalhes.removeClass('campoErro');
                        hideMsgAguardo();

                        if (cCddopcao.val() == "I") {

							showConfirmacao('078 - Confirma inclus&atilde;o da Proposta BNDES? (S/N)',"Confirma&ccedil;&atilde;o - Ayllos",'validacaoRating(2);','cVlempbnd.focus();',"sim.gif","nao.gif");

                        }else
                        if (cCddopcao.val() == "A") {

							showConfirmacao('078 - Confirma altera&ccedil;&atilde;o proposta BNDES? (S/N)',"Confirma&ccedil;&atilde;o - Ayllos",'validacaoRating(2);','cVlempbnd.focus();',"sim.gif","nao.gif");

						}
                    } catch(error) {
                        hideMsgAguardo();

                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                    }
                } else {
                    try {
                        eval(response);

                        return false;
                    } catch(error) {
                        hideMsgAguardo();

                        showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','estadoInicial();');
                    }
                }
            } catch(error) {
                showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message,"Alerta - Ayllos","blockBackground(parseInt($('#divRotina').css('z-index')))");
                hideMsgAguardo();
            }
        }
    });

    return false;
}


function validacaoRating(valor){

    var cddopcao = cCddopcao.val();
    var nrdconta = cNrdconta.val();
    nrdconta = nrdconta.replace(/[-. ]*/g,'');
    inpessoa = inpessoa;
    nrcpfcgc = nrcpfcgc;
    vlempbnd = cVlempbnd.val();
    qtparbnd = cQtparbnd.val();
    nrinfcad = cNrinfcad.val();
    nrgarope = cNrgarope.val();
    nrliquid = cNrliquid.val();
    nrpatrim = cNrpatrim.val();
    nrperger = cNrperger.val();
    var inconfir = valor;


    if (inpessoa == 1) {

        showMsgAguardo('Aguarde, validando contrato...');

    }else {

        showMsgAguardo('Aguarde, validando rating...');

    }


    $.ajax({
        type	: 'POST',
        dataType: 'html',
        url		: UrlSite + 'telas/'+nometela+'/validacao_rating_bndes.php',
        data    :
                { cddopcao	: cddopcao,
                  nrdconta  : nrdconta,
                  inpessoa  : inpessoa,
                  nrcpfcgc  : nrcpfcgc,
                  vlempbnd  : vlempbnd,
                  qtparbnd  : qtparbnd,
                  nrinfcad  : nrinfcad,
                  nrgarope  : nrgarope,
                  nrliquid  : nrliquid,
                  nrpatrim  : nrpatrim,
                  nrperger  : nrperger,
                  inconfir  : inconfir,
                  redirect: 'html_ajax'
                },
        error   : function(objAjax,responseError,objExcept) {
                    hideMsgAguardo();
                    showError('error','Não foi possível concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
                },
        success : function(response) {
            try {
                try {

                    eval(response);

                    if (aux_retorno == 'sucesso' && aux_inconfir == 2) {

                        aux_inconfir = 3;
                        validacaoRating(aux_inconfir);

                    }else
                    if (aux_retorno == 'critica' && aux_inconfir == 2) {

                        aux_inconfir = 3;
                        showConfirmacao(mensagem,"Confirma&ccedil;&atilde;o - Ayllos",'validacaoRating(aux_inconfir);','estadoInicial();btnOK.removeAttr("disabled");hideMsgAguardo();',"sim.gif","nao.gif");

                    }else
                    if (aux_retorno == 'erro') {

                        aux_inconfir = 2;
						if (existeGrupo > 0) { // Se houver grupo economico
							showError('error',mensagem,'Alerta - Ayllos','blockBackground(parseInt($("#divRotina").css("z-index")));');
						}else { // Não tem grupo economico, finaliza a operação
							showError('error',mensagem,'Alerta - Ayllos','estadoInicial();btnOK.removeAttr("disabled");hideMsgAguardo();');
						}

                    }
                } catch(error) {
                    if  (response.indexOf('formataGrupoEconomico();') > 0) {

                        txtGrupoEco = response.substring(1,response.indexOf('formataGrupoEconomico();') + 25);
                        txtCriticas = response.substring(response.indexOf('formataGrupoEconomico();') + 25,response.length);
                        eval(txtGrupoEco);

                     } else {

                        $('#divUsoGenerico').html(response);

                     }
                }
            } catch(error) {
                hideMsgAguardo();
                showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Ayllos','');
            }
        }
    });

    return false;
}


function mostraMsgsGrupoEconomico(){

    if(strHTML != ''){

        // Coloca conteúdo HTML no div
        $("#divListaMsgsGrupoEconomico").html(strHTML);

        // Mostra div
        $("#divMsgsGrupoEconomico").css("visibility","visible");

        exibeRotina($("#divMsgsGrupoEconomico"));

        // Esconde mensagem de aguardo
        hideMsgAguardo();

        // Bloqueia conteúdo que está átras do div de mensagens
        blockBackground(parseInt($("#divMsgsGrupoEconomico").css("z-index")));

    }

    return false;
}


function formataGrupoEconomico(){

    var divRegistro = $('div.divRegistros','#divMsgsGrupoEconomico');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'140px'});

    $('#divListaMsgsGrupoEconomico').css({'height':'200px'});

    var ordemInicial = new Array();

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';

    tabela.formataTabela( ordemInicial, '', arrayAlinha );

    return false;

}


function encerraMsgsGrupoEconomico(){

	/************************
	Função para fechar janela
	do grupo economico
	************************/

    // Esconde div
    $("#divMsgsGrupoEconomico").css("visibility","hidden");


    $("#divListaMsgsGrupoEconomico").html("&nbsp;");


    unblockBackground();
    dsmetodo = '';


    if (aux_retorno == 'sucesso') {

        if (cCddopcao.val() == "I") { // Incluir

            dsmetodo = "incluirRegistro();";

        }else
        if (cCddopcao.val() == "A") { // Alterar

            dsmetodo = "alterarRegistro();";

        }
    } else {

		btnOK.removeAttr('disabled');
		estadoInicial();
        dsmetodo = '';

    }


    if (txtCriticas != '') {

        $('#divUsoGenerico').html(txtCriticas);

    }

	eval(dsmetodo);

    return false;
}


function fechaRating(){

	/*****************
	Função que fecha
	janela de criticas
	*****************/

    fechaRotina($('#divUsoGenerico'),divRotina);
	btnOK.removeAttr('disabled');
    estadoInicial();

    return false;
}


/************************************************************************
 Fonte: descontos.js                                              
 Autor: Guilherme                                                 
 Data : Novembro/2008                Última Alteração: 30/04/2015
																  
 Objetivo  : Biblioteca de funções da rotina de Descontos da tela 
			 ATENDA                                               
																	 
 Alterações: 09/06/2010 - Incluir função dscShowHideDiv (David).         
 
			 09/07/2012 - Inclusão de tratamento para novos campos do frame 'frmTitulos'
						  dentro da função 'formataLayout()' (Lucas). 
			 19/11/2012 - Ajustes:
						  - Incluído tratamento na função formataLayout para quando, 
						    pressionado	a tecla enter nos campos dos forms frmDadosLimiteDscChq,
							frmDadosLimiteDscTit (Adriano).
						 
			 30/04/2015 - Ajustes na largura da tela dos avais (Gabriel-RKAM).

             25/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).			 
						  
************************************************************************/

// Carrega biblioteca javascript referente ao RATING
$.getScript(UrlSite + 'includes/rating/rating.js');

// Função para voltar para o div anterior conforme parâmetros
function voltaDiv(esconder, mostrar, qtdade, titulo, rotina, novotam, novalar) {

    if (rotina != undefined && rotina != "") {
        // Executa script de alteração de nome da rotina na seção através de ajax
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/altera_secao_nmrotina.php",
            data: {
                nmrotina: rotina
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            }
        });
    }

    var tamanho = novotam == undefined ? 80 : novotam;
    var largura = novalar == undefined ? 350 : novalar;

    if (titulo != undefined || titulo != "") {
        $("#tdTitRotina").html(titulo);
    }

    $("#divConteudoOpcao").css("height", tamanho);
    $("#divConteudoOpcao").css("width", largura);

    if (mostrar == 0) {
        for (var i = 1; i <= qtdade; i++) {
            $("#divOpcoesDaOpcao" + i).css("display", "none");
        }

        $("#divConteudoOpcao").css("display", "block");
    } else {
        $("#divConteudoOpcao").css("display", "none");

        for (var i = 1; i <= qtdade; i++) {
            $("#divOpcoesDaOpcao" + i).css("display", (mostrar == i ? "block" : "none"));
        }
    }
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > :input[type=image]").addClass("FluxoNavega");
        $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");

        //Se estiver com foco na classe FluxoNavega
        $(".FluxoNavega").focus(function () {
            $(this).bind('keydown', function (e) {
                if (e.keyCode == 13) {
                    $(this).click();
                }
            });
        });
    });
    $(".FirstInputModal").focus();
}

// Função para mostrar div com formulário de dados para digitação ou consulta
function dscShowHideDiv(show, hide) {
    var divShow = show.split(";");
    var divHide = hide.split(";");

    for (var i = 0; i < divShow.length; i++) {
        $("#" + divShow[i]).css("display", "block");
    }

    for (var i = 0; i < divHide.length; i++) {
        $("#" + divHide[i]).css("display", "none");
    }
}

// Função para bloqueio do background do divRotina
function metodoBlock() {
    blockBackground(parseInt($("#divRotina").css("z-index")));
}

// ROTINA TITULOS
// Mostrar o <div> sobre desconto de títulos
function carregaTitulos() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados de desconto de t&iacute;tulos ...");

    // Carrega biblioteca javascript da rotina
    // Ao carregar efetua chamada do conteúdo da rotina através de ajax
    $.getScript(UrlSite + "telas/atenda/descontos/titulos/titulos.js", function () {
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/titulos/titulos.php",
            dataType: "html",
            data: {
                nrdconta: nrdconta,
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                $("#divOpcoesDaOpcao1").html(response);
            }
        });
    });
}

// ROTINA CHEQUES
// Mostrar o <div> sobre desconto de cheques
function carregaCheques() {
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando dados de desconto de cheques ...");

    // Carrega biblioteca javascript da rotina
    // Ao carregar efetua chamada do conteúdo da rotina através de ajax
    $.getScript(UrlSite + "telas/atenda/descontos/cheques/cheques.js", function () {
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/atenda/descontos/cheques/cheques.php",
            dataType: "html",
            data: {
                nrdconta: nrdconta,
                redirect: "html_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
            },
            success: function (response) {
                $("#divOpcoesDaOpcao1").html(response);
            }
        });
    });
}

// Função para formata o layout
function controlaLayout() {

    layoutPadrao();

    return false;
}

function formataLayout(nomeForm) {

    if (typeof nomeForm == 'undefined') { return false; }

    $('#' + nomeForm).addClass('formulario');

    if (nomeForm == 'frmCheques') {

        var Lnrctrlim = $('label[for="nrctrlim"]', '#' + nomeForm);
        var Ldtinivig = $('label[for="dtinivig"]', '#' + nomeForm);
        var Lqtdiavig = $('label[for="qtdiavig"]', '#' + nomeForm);
        var Lvllimite = $('label[for="vllimite"]', '#' + nomeForm);
        var Lqtrenova = $('label[for="qtrenova"]', '#' + nomeForm);
        var Ldsdlinha = $('label[for="dsdlinha"]', '#' + nomeForm);
        var Lvlutiliz = $('label[for="vlutiliz"]', '#' + nomeForm);

        var Cnrctrlim = $('#nrctrlim', '#' + nomeForm);
        var Cdtinivig = $('#dtinivig', '#' + nomeForm);
        var Cqtdiavig = $('#qtdiavig', '#' + nomeForm);
        var Cvllimite = $('#vllimite', '#' + nomeForm);
        var Cqtrenova = $('#qtrenova', '#' + nomeForm);
        var Cdsdlinha = $('#dsdlinha', '#' + nomeForm);
        var Cvlutiliz = $('#vlutiliz', '#' + nomeForm);

        $('#' + nomeForm).css('width', '430px');

        Lnrctrlim.addClass('rotulo').css('width', '80px');
        Ldtinivig.css('width', '60px');
        Lqtdiavig.css('width', '60px');
        Lvllimite.addClass('rotulo').css('width', '80px');
        Lqtrenova.css('width', '158px');
        Ldsdlinha.addClass('rotulo').css('width', '155px');
        Lvlutiliz.addClass('rotulo').css('width', '155px');

        Cnrctrlim.css({ 'width': '60px', 'text-align': 'right' });
        Cdtinivig.css({ 'width': '65px', 'text-align': 'center' });
        Cqtdiavig.css({ 'width': '60px', 'text-align': 'right' });
        Cvllimite.css({ 'width': '90px', 'text-align': 'right' });
        Cqtrenova.css({ 'width': '60px', 'text-align': 'right' });
        Cdsdlinha.css({ 'width': '200px' });
        Cvlutiliz.css({ 'width': '150px', 'text-align': 'right' });

        Cnrctrlim.desabilitaCampo();
        Cdtinivig.desabilitaCampo();
        Cqtdiavig.desabilitaCampo();
        Cvllimite.desabilitaCampo();
        Cqtrenova.desabilitaCampo();
        Cdsdlinha.desabilitaCampo();
        Cvlutiliz.desabilitaCampo();

    } else if (nomeForm == 'divBorderos') {

        $('#' + nomeForm).css('width', '490px');

        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);

        divRegistro.css('height', '110px');

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '60px';
        arrayLargura[1] = '55px';
        arrayLargura[2] = '60px';
        arrayLargura[3] = '55px';
        arrayLargura[4] = '100px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'right';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'right';
        arrayAlinha[5] = 'left';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
                $(this).focus();
            }
        });

    } else if (nomeForm == 'frmBordero') {

        var Ldspesqui = $('label[for="dspesqui"]', '#' + nomeForm);
        var Lnrborder = $('label[for="nrborder"]', '#' + nomeForm);
        var Lnrctrlim = $('label[for="nrctrlim"]', '#' + nomeForm);
        var Ldsdlinha = $('label[for="dsdlinha"]', '#' + nomeForm);
        var Lqttitulo = $('label[for="qttitulo"]', '#' + nomeForm);
        var Ldsopedig = $('label[for="dsopedig"]', '#' + nomeForm);
        var Lvltitulo = $('label[for="vltitulo"]', '#' + nomeForm);
        var Ltxmensal = $('label[for="txmensal"]', '#' + nomeForm);
        var Ldtlibbdt = $('label[for="dtlibbdt"]', '#' + nomeForm);
        var Ltxdiaria = $('label[for="txdiaria"]', '#' + nomeForm);
        var Ldsopelib = $('label[for="dsopelib"]', '#' + nomeForm);
        var Ltxjurmor = $('label[for="txjurmor"]', '#' + nomeForm);

        var Cdspesqui = $('#dspesqui', '#' + nomeForm);
        var Cnrborder = $('#nrborder', '#' + nomeForm);
        var Cnrctrlim = $('#nrctrlim', '#' + nomeForm);
        var Cdsdlinha = $('#dsdlinha', '#' + nomeForm);
        var Cqttitulo = $('#qttitulo', '#' + nomeForm);
        var Cdsopedig = $('#dsopedig', '#' + nomeForm);
        var Cvltitulo = $('#vltitulo', '#' + nomeForm);
        var Ctxmensal = $('#txmensal', '#' + nomeForm);
        var Cdtlibbdt = $('#dtlibbdt', '#' + nomeForm);
        var Ctxdiaria = $('#txdiaria', '#' + nomeForm);
        var Cdsopelib = $('#dsopelib', '#' + nomeForm);
        var Ctxjurmor = $('#txjurmor', '#' + nomeForm);

        $('#' + nomeForm).css('width', '480px');

        Ldspesqui.addClass('rotulo').css('width', '170px');
        Lnrborder.addClass('rotulo').css('width', '170px');
        Lnrctrlim.css('width', '72px');
        Ldsdlinha.addClass('rotulo').css('width', '170px');

        Lqttitulo.addClass('rotulo').css('width', '110px');
        Ldsopedig.css('width', '110px');
        Lvltitulo.addClass('rotulo').css('width', '110px');
        Ltxmensal.addClass('rotulo').css('width', '110px');
        Ldtlibbdt.css('width', '110px');
        Ltxdiaria.addClass('rotulo').css('width', '110px');
        Ldsopelib.css('width', '110px');
        Ltxjurmor.addClass('rotulo').css('width', '110px');

        Cdspesqui.css({ 'width': '200px' });
        Cnrborder.css({ 'width': '60px', 'text-align': 'right' });
        Cnrctrlim.css({ 'width': '65px', 'text-align': 'right' });
        Cdsdlinha.css({ 'width': '200px' });
        Cqttitulo.css({ 'width': '100px', 'text-align': 'right' });
        Cdsopedig.css({ 'width': '100px' });
        Cvltitulo.css({ 'width': '100px', 'text-align': 'right' });
        Ctxmensal.css({ 'width': '100px', 'text-align': 'right' });
        Cdtlibbdt.css({ 'width': '100px' });
        Ctxdiaria.css({ 'width': '100px', 'text-align': 'right' });
        Cdsopelib.css({ 'width': '100px' });
        Ctxjurmor.css({ 'width': '100px' });

        Cdspesqui.desabilitaCampo();
        Cnrborder.desabilitaCampo();
        Cnrctrlim.desabilitaCampo();
        Cdsdlinha.desabilitaCampo();
        Cqttitulo.desabilitaCampo();
        Cdsopedig.desabilitaCampo();
        Cvltitulo.desabilitaCampo();
        Ctxmensal.desabilitaCampo();
        Cdtlibbdt.desabilitaCampo();
        Ctxdiaria.desabilitaCampo();
        Cdsopelib.desabilitaCampo();
        Ctxjurmor.desabilitaCampo();

    } else if (nomeForm == 'divLimites') {

        $('#' + nomeForm).css('width', '533px');

        var divRegistro = $('div.divRegistros', '#' + nomeForm);
        var tabela = $('table', divRegistro);

        divRegistro.css('height', '135px');

        var ordemInicial = new Array();

        var arrayLargura = new Array();
        arrayLargura[0] = '60px';
        arrayLargura[1] = '60px';
        arrayLargura[2] = '60px';
        arrayLargura[3] = '80px';
        arrayLargura[4] = '30px';
        arrayLargura[5] = '25px';
        arrayLargura[6] = '65px';

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'center';
        arrayAlinha[2] = 'right';
        arrayAlinha[3] = 'right';
        arrayAlinha[4] = 'center';
        arrayAlinha[5] = 'right';
        arrayAlinha[6] = 'left';
        arrayAlinha[7] = 'center';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $('tbody > tr', tabela).each(function () {
            if ($(this).hasClass('corSelecao')) {
                $(this).focus();
            }
        });

        ajustarCentralizacao();

    } else if (nomeForm == 'frmDadosLimiteDscChq' ||
			   nomeForm == 'frmDadosLimiteDscTit') {

        var Lnrctrlim = $('label[for="nrctrlim"]', '#' + nomeForm);
        var Lvllimite = $('label[for="vllimite"]', '#' + nomeForm);
        var Lqtdiavig = $('label[for="qtdiavig"]', '#' + nomeForm);
        var Lcddlinha = $('label[for="cddlinha"]', '#' + nomeForm);

        var Cnrctrlim = $('#nrctrlim', '#' + nomeForm);
        var Cvllimite = $('#vllimite', '#' + nomeForm);
        var Cqtdiavig = $('#qtdiavig', '#' + nomeForm);
        var Ccddlinha = $('#cddlinha', '#' + nomeForm);
        var Ccddlinh2 = $('#cddlinh2', '#' + nomeForm);


        var Ltxjurmor = $('label[for="txjurmor"]', '#' + nomeForm);
        var Ltxdmulta = $('label[for="txdmulta"]', '#' + nomeForm);
        var Ldsramati = $('label[for="dsramati"]', '#' + nomeForm);
        var Lvlmedtit = $('label[for="vlmedtit"]', '#' + nomeForm);
        var Lvlfatura = $('label[for="vlfatura"]', '#' + nomeForm);
        var Ldtcancel = $('label[for="dtcancel"]', '#' + nomeForm);

        var Ctxjurmor = $('#txjurmor', '#' + nomeForm);
        var Ctxdmulta = $('#txdmulta', '#' + nomeForm);
        var Cdsramati = $('#dsramati', '#' + nomeForm);
        var Cvlmedtit = $('#vlmedtit', '#' + nomeForm);
        var Cvlfatura = $('#vlfatura', '#' + nomeForm);
        var Cdtcancel = $('#dtcancel', '#' + nomeForm);


        var Llbrendas = $('label[for="lbrendas"]', '#' + nomeForm);
        var Lvlsalari = $('label[for="vlsalari"]', '#' + nomeForm);
        var Lvlsalcon = $('label[for="vlsalcon"]', '#' + nomeForm);
        var Lvloutras = $('label[for="vloutras"]', '#' + nomeForm);
        var Ldsdbens1 = $('label[for="dsdbens1"]', '#' + nomeForm);
        var Ldsdbens2 = $('label[for="dsdbens2"]', '#' + nomeForm);

        var Cvlsalari = $('#vlsalari', '#' + nomeForm);
        var Cvlsalcon = $('#vlsalcon', '#' + nomeForm);
        var Cvloutras = $('#vloutras', '#' + nomeForm);
        var Cdsdbens1 = $('#dsdbens1', '#' + nomeForm);
        var Cdsdbens2 = $('#dsdbens2', '#' + nomeForm);


        var Ldsobserv = $('label[for="dsobserv"]', '#' + nomeForm);
        var Cdsobserv = $('#dsobserv', '#' + nomeForm);

        $('#' + nomeForm).css('width', '515px');

        Lnrctrlim.addClass('rotulo').css('width', '150px');
        Lvllimite.addClass('rotulo').css('width', '150px');
        Lqtdiavig.css('width', '130px');
        Lcddlinha.addClass('rotulo').css('width', '150px');
        Ltxjurmor.addClass('rotulo').css('width', '150px');
        Ltxdmulta.addClass('rotulo').css('width', '150px');
        Ldsramati.addClass('rotulo').css('width', '150px');
        Lvlmedtit.addClass('rotulo').css('width', '150px');
        Lvlfatura.addClass('rotulo').css('width', '150px');
        Ldtcancel.css('width', '130px');

        Cnrctrlim.css({ 'width': '100px', 'text-align': 'right' });
        Cvllimite.css({ 'width': '100px', 'text-align': 'right' });
        Cqtdiavig.css({ 'width': '65px', 'text-align': 'right' });
        Ccddlinha.css({ 'width': '40px', 'text-align': 'right' });
        Ccddlinh2.css({ 'width': '255px' });
        Ctxjurmor.css({ 'width': '100px', 'text-align': 'right' });
        Ctxdmulta.css({ 'width': '100px', 'text-align': 'right' });
        Cdsramati.css({ 'width': '300px' });
        Cvlmedtit.css({ 'width': '100px', 'text-align': 'right' });
        Cvlfatura.css({ 'width': '100px', 'text-align': 'right' });
        Cdtcancel.css({ 'width': '65px' });


        Llbrendas.addClass('rotulo').css('width', '80px');
        Lvlsalari.css('width', '50px');
        Lvlsalcon.addClass('rotulo-linha');
        Lvloutras.addClass('rotulo').css('width', '130px');
        Ldsdbens1.addClass('rotulo').css('width', '80px');
        Ldsdbens2.addClass('rotulo').css('width', '80px');

        Cvlsalari.css({ 'width': '100px', 'text-align': 'right' });
        Cvlsalcon.css({ 'width': '100px', 'text-align': 'right' });
        Cvloutras.css({ 'width': '100px', 'text-align': 'right' });
        Cdsdbens1.css({ 'width': '350px', 'text-align': 'left' });
        Cdsdbens2.css({ 'width': '350px', 'text-align': 'left' });

        Cdsobserv.addClass('alphanum').css({ 'width': '485px', 'height': '80px', 'float': 'left', 'margin': '3px 0px 3px 3px', 'padding-right': '1px' });


        Cnrctrlim.unbind('keypress').bind('keypress', function (e) {

            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 13) {

                Cvllimite.focus();

            }

        });

        Cvllimite.unbind('keypress').bind('keypress', function (e) {

            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 13) {

                Ccddlinha.focus();

            }

        });

        Cdsramati.unbind('keypress').bind('keypress', function (e) {

            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 13) {

                Cvlmedtit.focus();

            }

        });

        Cvlmedtit.unbind('keypress').bind('keypress', function (e) {

            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 13) {

                Cvlfatura.focus();

            }

        });

        Cvlsalari.unbind('keypress').bind('keypress', function (e) {

            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 13) {

                Cvlsalcon.focus();

            }

        });

        Cvlsalcon.unbind('keypress').bind('keypress', function (e) {

            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 13) {

                Cvloutras.focus();

            }

        });

        Cvloutras.unbind('keypress').bind('keypress', function (e) {

            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 13) {

                Cdsdbens1.focus();

            }

        });

        Cdsdbens1.unbind('keypress').bind('keypress', function (e) {

            /*Se foi pressionado a telca ENTER*/
            if (e.keyCode == 13) {

                Cdsdbens2.focus();

            }

        });



    } else if (nomeForm == 'frmTitulos') {

        var Lnrctrlim = $('label[for="nrctrlim"]', '#' + nomeForm);
        var Ldtinivig = $('label[for="dtinivig"]', '#' + nomeForm);
        var Lqtdiavig = $('label[for="qtdiavig"]', '#' + nomeForm);
        var Lvllimite = $('label[for="vllimite"]', '#' + nomeForm);
        var Lqtrenova = $('label[for="qtrenova"]', '#' + nomeForm);
        var Ldsdlinha = $('label[for="dsdlinha"]', '#' + nomeForm);
        var Lvlutilcr = $('label[for="vlutilcr"]', '#' + nomeForm);
        var Lvlutilsr = $('label[for="vlutilsr"]', '#' + nomeForm);

        var Cnrctrlim = $('#nrctrlim', '#' + nomeForm);
        var Cdtinivig = $('#dtinivig', '#' + nomeForm);
        var Cqtdiavig = $('#qtdiavig', '#' + nomeForm);
        var Cvllimite = $('#vllimite', '#' + nomeForm);
        var Cqtrenova = $('#qtrenova', '#' + nomeForm);
        var Cdsdlinha = $('#dsdlinha', '#' + nomeForm);
        var Cvlutilcr = $('#vlutilcr', '#' + nomeForm);
        var Cvlutilsr = $('#vlutilsr', '#' + nomeForm);

        $('#' + nomeForm).css('width', '430px');

        Lnrctrlim.addClass('rotulo').css('width', '80px');
        Ldtinivig.css('width', '60px');
        Lqtdiavig.css('width', '60px');
        Lvllimite.addClass('rotulo').css('width', '80px');
        Lqtrenova.css('width', '158px');
        Ldsdlinha.addClass('rotulo').css('width', '155px');
        Lvlutilcr.addClass('rotulo').css('width', '200px');
        Lvlutilsr.addClass('rotulo').css('width', '200px');


        Cnrctrlim.css({ 'width': '60px', 'text-align': 'right' });
        Cdtinivig.css({ 'width': '65px', 'text-align': 'center' });
        Cqtdiavig.css({ 'width': '60px', 'text-align': 'right' });
        Cvllimite.css({ 'width': '90px', 'text-align': 'right' });
        Cqtrenova.css({ 'width': '60px', 'text-align': 'right' });
        Cdsdlinha.css({ 'width': '200px' });
        Cvlutilcr.css({ 'width': '150px', 'text-align': 'right' });
        Cvlutilsr.css({ 'width': '150px', 'text-align': 'right' });

        Cnrctrlim.desabilitaCampo();
        Cdtinivig.desabilitaCampo();
        Cqtdiavig.desabilitaCampo();
        Cvllimite.desabilitaCampo();
        Cqtrenova.desabilitaCampo();
        Cdsdlinha.desabilitaCampo();
        Cvlutilcr.desabilitaCampo();
        Cvlutilsr.desabilitaCampo();

    }

    return false;
}


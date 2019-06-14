/***********************************************************************
      Fonte: consorcio.js
      Autor: Lucas R.
      Data : Julho/2013                &Uacute;ltima Altera&ccedil;&atilde;o: 00/00/0000

      Objetivo  : Biblioteca de fun&ccedil;&otilde;es da rotina CONSORCIO da tela
                  ATENDA

      Altera&ccedil;&otilde;es:
	  25/07/2016 - Adicionado função controlaFoco.(Evandro - RKAM).
              	  
 ***********************************************************************/
var glbNrcotcns;

arrConsorcio = new Array();

// Fun&ccedil;&atilde;o para acessar op&ccedil;&otilde;es da rotina
function acessaOpcaoAba(nrOpcoes, id, opcao) {
    if (opcao == "0") {	// Op&ccedil;&atilde;o Principal
        var msg = "consorcios";
    }
    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando " + msg + " ...");

    // Atribui cor de destaque para aba da op&ccedil;&atilde;o
    for (var i = 0; i < nrOpcoes; i++) {
        if (id == i) { // Atribui estilos para foco da op&ccedil;&atilde;o
            $("#linkAba" + id).attr("class", "txtBrancoBold");
            $("#imgAbaEsq" + id).attr("src", UrlImagens + "background/mnu_sle.gif");
            $("#imgAbaDir" + id).attr("src", UrlImagens + "background/mnu_sld.gif");
            $("#imgAbaCen" + id).css("background-color", "#969FA9");
            continue;
        }

        $("#linkAba" + i).attr("class", "txtNormalBold");
        $("#imgAbaEsq" + i).attr("src", UrlImagens + "background/mnu_nle.gif");
        $("#imgAbaDir" + i).attr("src", UrlImagens + "background/mnu_nld.gif");
        $("#imgAbaCen" + i).css("background-color", "#C6C8CA");
    }

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/atenda/consorcio/principal.php",
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')) )");
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1) {
                hideMsgAguardo();
                $('#divConteudoOpcao').html(response);

            } else {
                eval(response);
            }
            controlaFoco();
            return false;
        }
    });
}

//Função para controle de navegação
function controlaFoco() {
    $('#divConteudoOpcao').each(function () {
        $(this).find("#divBotoes > :input[type=image]").first().addClass("FirstInputModal").focus();
        $(this).find("#divBotoes > :input[type=image]").last().addClass("LastInputModal");
        if ($('.LastInputModal').css({ 'display': 'none' })) {//Se LastInputModal for disabled
            $('#divConteudoOpcao #btVoltar').addClass("LastInputModal");
            $('#divConteudoOpcao').find("#divBotoes > :input[type=image]").last().removeClass("LastInputModal");
        }
    });

    $(".LastInputModal").focus(function () {
        var pressedShift = false;

        $(this).bind('keyup', function (e) {
            if (e.keyCode == 16) {
                pressedShift = false;//Quando tecla shift for solta passa valor false 
            }
        })

        $(this).bind('keydown', function (e) {
            e.stopPropagation();
            e.preventDefault();

            if (e.keyCode == 13) {
                $('.LastInputModal').click();
            }

            if (e.keyCode == 16) {
                pressedShift = true;//Quando tecla shift for pressionada passa valor true 
            }
            if ((e.keyCode == 9) && pressedShift == true) {
                return setFocusCampo($(target), e, false, 0);
            }
            else if (e.keyCode == 9) {
                $(".FirstInputModal").focus();
            }
        });

    });

    $(".FirstInputModal").focus();
}

// Função para formata o layout
function controlaLayout() {

    $('#divConteudoOpcao').css('display', 'block');

    divRotina.css('width', '645px');
    $('#divConteudoOpcao').css({ 'height': '245px', 'width': '645px' });

    // tabela	
    var divRegistro = $('div.divRegistros');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '180px', 'padding-bottom': '2px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 1]];

    var arrayLargura = new Array();
    arrayLargura[0] = '65px';
    arrayLargura[1] = '65px';
    arrayLargura[2] = '50px';
    arrayLargura[3] = '55px';
    arrayLargura[4] = '90px';
    arrayLargura[5] = '45px';
    arrayLargura[6] = '90px';
    arrayLargura[7] = '70px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'right';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';
    arrayAlinha[5] = 'right';
    arrayAlinha[6] = 'right';
    arrayAlinha[7] = 'right';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    $('#btConsultar', '#divBotoes').hide();

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).click(function () {
        glbNrcotcns = $(this).find('#nrcotcns > #tbnrcotcns').val();
        $('#btConsultar', '#divBotoes').show();
    });

    // seleciona o registro que é clicado
    $('table > tbody > tr', divRegistro).dblclick(function () {
        glbNrcotcns = $(this).find('#nrcotcns > #tbnrcotcns').val();
        btConsultar();
    });


    $('table > tbody > tr:eq(0)', divRegistro).click();

    layoutPadrao();

    $('input', '#divRegistros').trigger('blur');

    hideMsgAguardo();
    removeOpacidade('divRegistros');
    divRotina.centralizaRotinaH();
    bloqueiaFundo(divRotina);

}


function formataTela() {

    altura = '235px';
    largura = '560px';

    $('input', '#frmDadosConsorcio').limpaFormulario();
    $('#divConteudoOpcao').css('display', 'none');

    $('input, select', '#frmDadosConsorcio').removeClass('campoErro');

    $.each(arrConsorcio, function (i, object) {

        if (object.nrcotcns == glbNrcotcns) {

            $('#nrdgrupo', '#frmDadosConsorcio').val(object.nrdgrupo);
            $('#dsconsor', '#frmDadosConsorcio').val(object.dsconsor);
            $('#nrcotcns', '#frmDadosConsorcio').val(object.nrcotcns);
            $('#qtparcns', '#frmDadosConsorcio').val(object.qtparcns).setMask('INTEGER', '999', '', '');
            $('#parcpaga', '#frmDadosConsorcio').val(object.parcpaga);
            $('#dtinicns', '#frmDadosConsorcio').val(object.dtinicns);
            $('#dtdebito', '#frmDadosConsorcio').val(object.dtdebito);
            $('#dtfimcns', '#frmDadosConsorcio').val(object.dtfimcns);
            $('#instatus', '#frmDadosConsorcio').val(object.instatus);
            $('#vlrcarta', '#frmDadosConsorcio').val(object.vlrcarta);
            $('#vlparcns', '#frmDadosConsorcio').val(object.vlparcns);
            $('#nrctacns', '#frmDadosConsorcio').val(object.nrctacns).setMask('INTEGER', 'zzzz.zzz-z', '.-', '');
            $('#nrdiadeb', '#frmDadosConsorcio').val(object.nrdiadeb).setMask('INTEGER', '99', '', '');
            $('#nrctrato', '#frmDadosConsorcio').val(object.nrctrato).setMask('INTEGER', 'zzz.zzz.zz9', '.', '');

        }

    });

    var rRotulos = $('label[for="dsconsor"],label[for="nrcotcns"],label[for="nrctrato"],label[for="qtparcns"],label[for="vlrcarta"],label[for="vlparcns"],label[for="nrdgrupo"]', '#frmDadosConsorcio');
    var cTodos = $('select,input', '#frmDadosConsorcio');

    var rRotuloLinha = $('label[for="nrctacns"],label[for="dtinicns"],label[for="nrdiadeb"],label[for="parcpaga"],label[for="dtfimcns"],label[for="instatus"]', '#frmDadosConsorcio');
    var cMoeda = $('#vlrcarta,#vlparcns', '#frmDadosConsorcio');

    cMoeda.addClass('moeda');
    cTodos.addClass('campo').css('width', '131px');

    rRotulos.addClass('rotulo').css('width', '118px');
    rRotuloLinha.addClass('rotulo-linha').css('width', '138px');

    cTodos.desabilitaCampo();

    $('input', '#frmDadosConsorcio').trigger('blur');

    divRotina.css('width', largura);
    $('#divConteudoOpcao').css({ 'height': altura, 'width': largura });

    layoutPadrao();
    hideMsgAguardo();
    removeOpacidade('divConteudoOpcao');
    divRotina.centralizaRotinaH();
    bloqueiaFundo(divRotina);

}

function btConsultar() {


    // Executa script de atraves de ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/consorcio/form_consorcio.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'script_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)');
        },
        success: function (response) {
            if (response.indexOf('showError("error"') == -1) {
                hideMsgAguardo();
                $('#divConteudoOpcao').html(response);
                formataTela();
            } else {
                eval(response);
            }
            return false;
        }
    });

}

function criaObjetoConsorcio(nrcotcns, vlrcarta, qtparcns, vlparcns, dtinicns, dtdebito, dtfimcns, instatus, dsconsor, parcpaga, nrdgrupo, nrctacns, nrdiadeb, nrctrato) {

    var objConsorcio = new consorcio(nrcotcns, vlrcarta, qtparcns, vlparcns, dtinicns, dtdebito, dtfimcns, instatus, dsconsor, parcpaga, nrdgrupo, nrctacns, nrdiadeb, nrctrato);
    arrConsorcio.push(objConsorcio);

}

function consorcio(nrcotcns, vlrcarta, qtparcns, vlparcns, dtinicns, dtdebito, dtfimcns, instatus, dsconsor, parcpaga, nrdgrupo, nrctacns, nrdiadeb, nrctrato) {

    this.nrcotcns = nrcotcns;
    this.vlrcarta = vlrcarta;
    this.qtparcns = qtparcns;
    this.vlparcns = vlparcns;
    this.dtinicns = dtinicns;
    this.dtdebito = dtdebito;
    this.dtfimcns = dtfimcns;
    this.dsconsor = dsconsor;
    this.instatus = instatus;
    this.parcpaga = parcpaga;
    this.nrdgrupo = nrdgrupo;
    this.nrctacns = nrctacns;
    this.nrdiadeb = nrdiadeb;
    this.nrctrato = nrctrato;

}

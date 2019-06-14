/*!
 * FONTE        : cadsms.js
 * CRIAÇÃO      : Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 04/10/2016
 * OBJETIVO     : Biblioteca de funções da tela CADSMS
 * --------------
 * ALTERAÇÕES   :
 *
 *
 *
 *
 *
 * --------------
 */

var cddopcao = '';

var rCddopcao, rNmrescop,
    cCddopcao, cNmrescop, cCamposAltera;

var cabecalho;
var fomulario;
var grid;
var filtroGridPacotes;
var popup;


var lstCooperativas = new Array();

var frmCab = 'frmCab';

$(document).ready(function() {

    cabecalho = new Cabecalho();
    formulario = new FormularioPacote();
    grid = new Grid();
    filtroGridPacotes = new FiltroGridPacotes();
    popup = new PopupPacote();

    // cabecalho
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);
	rCddopcao		= $('label[for="cddopcao"]'	,'#frmCab');
	rNmrescop       = $('label[for="nmrescop"]'	,'#divCooper');

    cCddopcao		= $('#cddopcao'	,'#frmCab');
    cNmrescop       = $('#nmrescop'	,'#divCooper');

    //Opcao O
    rFlofesms		= $('label[for="flofesms"]'	,'#frmOpcaoO');
	rDtiniofe		= $('label[for="dtiniofe"]'	,'#frmOpcaoO');
    rDtfimofe		= $('label[for="dtfimofe"]'	,'#frmOpcaoO');

    cFlofesms       = $('#flofesms'	,'#frmOpcaoO');
    cDtiniofe		= $('#dtiniofe'	,'#frmOpcaoO');
    cDtfimofe		= $('#dtfimofe'	,'#frmOpcaoO');
    cDsmensag		= $('#dsmensag'	,'#frmOpcaoO');

    //Opcao M
    rFllindig		= $('label[for="fllindig"]'	,'#frmOpcaoM');
    cFllindig       = $('#fllindig'	,'#frmOpcaoM');

    //Opcao P
    rNrdialau		= $('label[for="nrdialau"]'	,'#frmOpcaoP');
    cNrdialau       = $('#nrdialau'	,'#frmOpcaoP');

    estadoInicial();

});


function Cabecalho() {

    Cabecalho.onChangeOpcao = function(componenteOpcoes) {
        Cabecalho.inicializarComponenteOpcao(componenteOpcoes);
    }

    var ehParaRemoverOpcaoTodas = function(opcaoSelecionada) {

        var opcoesParaCooperativa = ["A", "C", "I"]; //Opções que não devem ter a opção Todas

        for (var i = 0, len = opcoesParaCooperativa.length; i < len; i++) {
            if (opcoesParaCooperativa[i] == opcaoSelecionada)
                return true;
        }
        return false;
    }

    Cabecalho.inicializarComponenteOpcao = function(componenteOpcoes) {

        if (ehParaRemoverOpcaoTodas(componenteOpcoes.value)) {
            removerOpcaoTodas();
        }
        else
        {
            if($("#nmrescop option[value='0']").length == 0) {
                adicionarOpcaoTodas();
                getComponenteCooperativas().val('0');
            }
        }
    }

    this.getOpcaoSelecionada = function() {
        return getComponenteOpcoes().val();
    }

    var removerOpcaoTodas = function() {
        if($("#nmrescop option[value='0']").length > 0) {
            $("#nmrescop option[value='0']").remove();
        }
    }

    var adicionarOpcaoTodas = function() {
        getComponenteCooperativas().prepend($('<option>', {
            value: 0,
            text: 'Todas'
        }));
    }

    this.desabilitarTodosComponentes = function() {
        getTodosComponentes().desabilitaCampo();
    }

    var getTodosComponentes = function() {
        return $('input[type="text"],select', '#frmCab');
    }

    var getComponenteOpcoes = function() {
        return $('#cddopcao', '#frmCab');
    }

    var getComponenteCooperativas = function() {
        return $('#nmrescop', '#divCooper');
    }

    this.getCooperativaSelecionada = function() {
        return getComponenteCooperativas().val();
    }

    this.inicializar = function() {
        Cabecalho.inicializarComponenteOpcao(getComponenteOpcoes());
    }
}

function Grid() {

    var registroSelecionado;

    var selecionarRegistro = function(Id) {
        registroSelecionado = Id;
    }

    this.getRegistroSelecionado = function() {
        return registroSelecionado;
    }

    var totalRegistros = function(divRegistro) {
        return $('table > tbody > tr', divRegistro).size();
    }

    var existeRegistros = function(divRegistro) {
        return totalRegistros(divRegistro) > 0;
    }

    var selecionarPrimeiroRegistro = function(divRegistro) {

        if(existeRegistros(divRegistro)) {
            var primeiroRegistro = getTodosRegistros()[0];
            selecionarRegistro(primeiroRegistro.id);
        }
    }

    var getTodosRegistros = function() {
        return $('#divPacotes > .divRegistros > table > tbody > tr');
    }

    var formatarBotoes = function() {

        if(cabecalho.getOpcaoSelecionada() == "A") {
            $("#btDetalhar","#divGrid").hide();
            $("#btAlterar","#divGrid").show();
        } else {
            $("#btDetalhar","#divGrid").show();
            $("#btAlterar","#divGrid").hide();
        }
    }

    Grid.onClick_Detalhar = function() {

        $.ajax({
            type: "POST",
            async: false,
            dataType: 'html',
            url: UrlSite + "telas/cadsms/form_pacote.php",
            data: {
                idpacote: grid.getRegistroSelecionado(),
                cdcooper: cabecalho.getCooperativaSelecionada(),
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function() {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function(response) {
                if (response.substr(0, 16).indexOf("hideMsgAguardo") > -1) {
                    eval(response);
                } else {
                    popup.inicializar(response);
                }
            }
        });
    }

    Grid.onClick_Alterar = function() {

        $.ajax({
            type: "POST",
            async: false,
            dataType: 'html',
            url: UrlSite + "telas/cadsms/alterar_pacote.php",
            data: {
                idpacote: grid.getRegistroSelecionado(),
                cdcooper: cabecalho.getCooperativaSelecionada(),
                flgativo: 1,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function() {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function(response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                }
            }
        });
    }

    var formatar = function() {

        var divRegistro = $('div.divRegistros', '#divPacotes');
        var tabela = $('table', divRegistro);
        divRegistro.css({'height': '200px', 'width': '500px'});

        var tabelaHeader = $('table > thead > tr > th', divRegistro);
        var fonteLinha = $('table > tbody > tr > td', divRegistro);

        tabelaHeader.css({'font-size': '11px'});
        fonteLinha.css({'font-size': '11px'});

        $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
        $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});

        var ordemInicial = new Array();
        ordemInicial = [[0, 0]];

        var arrayLargura = new Array();
        arrayLargura[0] = '60px';
        arrayLargura[1] = '200px';
        arrayLargura[2] = '90px';
        arrayLargura[3] = '90px';
        //arrayLargura[4] = '90px';
        /*arrayLargura[5] = '97px';*/

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'center';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'center';
        arrayAlinha[3] = 'center';
        //arrayAlinha[4] = 'center';
        //arrayAlinha[5] = 'center';
        var metodoTabela = '';

        formatarBotoes();

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);

        if(existeRegistros(divRegistro)) {
            bindRegistrosGrid(divRegistro);
            selecionarPrimeiroRegistro(divRegistro);

            $('.headerSort').click(function() {
                bindRegistrosGrid(divRegistro);
            })
        }
    }

    var bindRegistrosGrid = function(divRegistro) {
        $('table > tbody > tr', divRegistro).click( function() {
            Grid.onRegistroClick(this);
        });
    }

    Grid.onRegistroClick = function(registro) {
        selecionarRegistro(registro.id);
    }

    Grid.carregar = function(cooperativa, flgstatus, pagina) {

        $.ajax({
            type: "POST",
            async: false,
            dataType: 'html',
            url: UrlSite + "telas/cadsms/consultar_pacotes.php",
            data: {
                cdcooper: cooperativa,
                flgstatus: flgstatus,
                pagina: pagina,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function() {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function(response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                } else {
                    $('#divGrid').css({'display':'block'});
                    $('#divGrid').html(response);
                    formatar();
                    hideMsgAguardo();
                }
            }
        });
    }
}

function PopupPacote() {

    this.inicializar = function(html) {
        $('#divRotina').html(html);
        exibeRotina($('#divRotina'));
        hideMsgAguardo();
        bloqueiaFundo($('#divRotina'));
        formatar();
    }

    var formatar = function () {

        desabilitarCampos();

        var opcaoSelecionada = cabecalho.getOpcaoSelecionada();

        if(opcaoSelecionada == "A") {
            habilitarAlteracoes();
        } else {
            $("#btPopupAlterar").hide();
        }

        $("#divRotina").css("left", "453px");
        $("#qtdsms").setMask('INTEGER', 'zzzzzzzz', '', '');
        //$("#perdesconto").addClass('moeda');
        //$("#perdesconto").setMask('INTEGER', 'zzzzzzzz', '', '');
        $("#perdesconto").setMask('DECIMAL','zzz.zzz.zzz.zz9,99',',','');

    }

    var habilitarAlteracoes = function () {

        getComponenteBotaoAlterar().show();
        getComponenteFlgStatus().habilitaCampo();
        getComponentePercentualDesconto().habilitaCampo();
        getComponenteQuantidadeSMS().habilitaCampo();

        $("#perdesconto").change(function() {
            calcularTarifa();
        });

        $("#qtdsms").change(function () {
            calcularTarifa();
        });
    }

    var getComponenteBotaoAlterar = function() {
        return $("#btPopupAlterar");
    }

    var calcularTarifa = function () {

        $.ajax({
            type: "POST",
            dataType: 'json',
            url: UrlSite + "telas/cadsms/calcular_tarifa.php",
            data: {
                cdcooper: cabecalho.getCooperativaSelecionada(),
                cdtarifa: popup.getIdTarifa(),
                qtdsms: popup.getQuantidadeSMS(),
                perdesconto: popup.getPercentualDesconto(),
                redirect: "script_ajax"
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                hideMsgAguardo();
                if (response.erro == undefined) {
                    $("#vlsms").val(response.vlsms);
                    $("#vlsmsad").val(response.vlsmsad);
                    $("#vlpacote").val(response.vlpacote);
                } else {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + response.erro + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
                }
            }
        });

    }

    var desabilitarCampos = function() {
        getTodosComponentes().desabilitaCampo();
    }

    var getTodosComponentes = function() {
        return $('input[type="text"],select', '#frmPacote');
    }

    this.getFlgStatusSelecionado = function() {
        return getComponenteFlgStatus().val();
    }

    this.getIdTarifa = function () {
        return $("#cdtarifa").val();
    }

    this.getPercentualDesconto = function () {
        return getComponentePercentualDesconto().val();
    }

    this.getQuantidadeSMS = function () {
        return getComponenteQuantidadeSMS().val();
    }

    var getComponentePercentualDesconto = function () {
        return $("#perdesconto");
    }

    var getComponenteQuantidadeSMS = function () {
        return $("#qtdsms");
    }

    var getComponenteFlgStatus = function() {
        return $("#flgstatus");
    }

    this.isValid = function() {

        var obj = new Object();
        obj.isValid = true;
        obj.Message = "";

        if(popup.getPercentualDesconto() == '') {
            obj.Message = "Campo Percentual de Desconto deve ser informado.";
            obj.isValid = false;
            return obj;
        }

        if(popup.getQuantidadeSMS() == '') {
            obj.Message = "Campo Quantidade de SMSs deve ser informado.";
            obj.isValid = false;
            return obj;
        }
        return obj;

    }

    PopupPacote.onClick_Alterar = function() {

        var validator = popup.isValid();

        if(!validator.isValid) {
            showError("error", validator.Message, "Alerta - Ayllos", "");
            return;
        }

        $.ajax({
            type: "POST",
            async: false,
            dataType: 'html',
            url: UrlSite + "telas/cadsms/alterar_pacote.php",
            data: {
                idpacote: grid.getRegistroSelecionado(),
                cdcooper: cabecalho.getCooperativaSelecionada(),
                flgstatus: popup.getFlgStatusSelecionado(),
                perdesconto: popup.getPercentualDesconto(),
                qtdsms: popup.getQuantidadeSMS(),
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function() {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function(response) {
                hideMsgAguardo();
                eval(response);
            }
        });
    }
}

function FiltroGridPacotes() {

    this.exibir = function() {
        getFormulario().show();
        habilitarFiltro();
        exibirBotoes();
    }

   var getFormulario = function() {
       return $('#frmFiltroGrid');
   }

    var getFiltroSelecionado = function() {
        return getComponenteFlgstatus().val();
    }

    var getComponenteFlgstatus = function() {
        return getFormulario().find("#flgstatus");
    }

    var exibirBotoes = function() {
        getComponenteBotoes().show();
    }

    var ocultarBotoes = function() {
        getComponenteBotoes().hide();
    }

    var getComponenteBotoes = function() {
        return getFormulario().find("#divBotoes");
    }

    var desabilitarFiltro = function() {
         getComponenteFlgstatus().desabilitaCampo();
    }

    var habilitarFiltro = function() {
        getComponenteFlgstatus().habilitaCampo();
    }

    FiltroGridPacotes.onClick_Prosseguir = function() {
        ocultarBotoes();
        desabilitarFiltro();
        Grid.carregar(cabecalho.getCooperativaSelecionada(), getFiltroSelecionado(), 1);
    }

}

function FormularioPacote() {

    this.exibir = function() {
        getFormulario().show();
    }

    this.ocultar = function() {
        getFormulario().hide();
    }

    var formatarCamposNumericos = function() {
        $("#vlpacote").setMask('DECIMAL','zzz.zzz.zzz.zz9,99',',','');
        $("#vlsmsad").setMask('DECIMAL','zzz.zzz.zzz.zz9,99',',','');
        $("#vlsms").setMask('DECIMAL','zzz.zzz.zzz.zz9,99',',','');
        $("#perdesconto").setMask('DECIMAL','zzz.zzz.zzz.zz9,99',',','');
        $("#qtdsms").setMask('INTEGER', 'zzzzzzzz', '', '');
        $("#cdtarifa").setMask('INTEGER', 'zzzzzzzz', '', '');
    }

    this.formatar = function() {
        this.exibir();
        formatarCamposNumericos();
        configurarIdPacote();
        configurarEventos();
   }

   var configurarEventos = function() {

       $("#frmOpcaoI #cdtarifa").unbind('blur').bind('blur', function() {
           FormularioPacote.calcularTarifa();
           FormularioPacote.configurarTipoPessoa();
       });

       $("#frmOpcaoI #perdesconto").unbind('blur').bind('blur', function() {
           FormularioPacote.calcularTarifa();
       });

       $("#frmOpcaoI #qtdsms").unbind('blur').bind('blur', function() {
           FormularioPacote.calcularTarifa();
       });
   }

   var getFormulario = function() {
       return $('#frmOpcaoI');
   }

   var setIdPacote = function(id) {
       $("#frmOpcaoI #idpacote").val(id);
   }

   this.isValid = function(pacote) {

       var obj = new Object();
       obj.isValid = true;
       obj.Message = "";

       if(pacote.dspacote == '') {
           obj.Message = "Campo Descri&ccedil;&atilde;o do Pacote deve ser informado.";
           obj.isValid = false;
           return obj;
       }

       if(pacote.cdtarifa == '') {
           obj.Message = "Campo C&oacute;digo da tarifa deve ser informado.";
           obj.isValid = false;
           return obj;
       }

       if(pacote.qtdsms == '') {
           obj.Message = "Campo Quantidade de SMSs deve ser informado.";
           obj.isValid = false;
           return obj;
       }
       return obj;
   }

   FormularioPacote.onClick_Prosseguir = function() {

        var pacote = formulario.toDictionary();
        var validator = formulario.isValid(pacote);

        if(!validator.isValid) {
            showError("error",validator.Message, "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            return;
        }

        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/cadsms/inserir_pacote.php",
            data: {
                cdcooper: cabecalho.getCooperativaSelecionada(),
                idpacote: $("#frmOpcaoI #idpacote").val(), //como está desabilitado na tela, não serializa
                dspacote: pacote.dspacote,
                flgstatus: pacote.flgstatus,
                cdtarifa: pacote.cdtarifa,
                perdesconto: pacote.perdesconto,
                inpessoa: $("#frmOpcaoI #inpessoa").val(), //como está desabilitado na tela, não serializa
                qtdsms: pacote.qtdsms,
                redirect: "script_ajax"
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function() {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function(response) {
                hideMsgAguardo();
                eval(response);
            }
});
   }

   FormularioPacote.configurarTipoPessoa = function() {
       var pacote = formulario.toDictionary();

       if(pacote.cdtarifa == '') {
           return;
       }

       $.ajax({
           type: "POST",
           dataType: 'json',
           url: UrlSite + "telas/cadsms/buscar_tipo_pessoa.php",
           data: {
               cdcooper: cabecalho.getCooperativaSelecionada(),
               cdtarifa: pacote.cdtarifa,
               redirect: "script_ajax"
           },
           error: function(objAjax, responseError, objExcept) {
               hideMsgAguardo();
               showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
           },
           beforeSend: function() {
               showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
           },
           success: function(response) {
               hideMsgAguardo();
               if(response.erro == undefined) {
                   $("#inpessoa").val(response.inpessoa);

               } else {
                   showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + response.erro + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
               }
           }
       });

   }

   var configurarIdPacote = function() {

       $.ajax({
           type: "POST",
           dataType: 'json',
           url: UrlSite + "telas/cadsms/buscar_id.php",
           data: {
               cdcooper: cabecalho.getCooperativaSelecionada(),
               redirect: "script_ajax"
           },
           error: function(objAjax, responseError, objExcept) {
               hideMsgAguardo();
               showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
           },
           beforeSend: function() {
               showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
           },
           success: function(response) {
               hideMsgAguardo();
               if(response.erro == undefined) {
                   setIdPacote(response.id);
               } else {
                   showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + response.erro + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
               }
           }
       });


   }

   FormularioPacote.calcularTarifa = function() {

        var pacote = formulario.toDictionary();

        if(pacote.cdtarifa == '' || pacote.qtdsms <= 0) {
            return;
        }

        $.ajax({
            type: "POST",
            dataType: 'json',
            url: UrlSite + "telas/cadsms/calcular_tarifa.php",
            data: {
                cdcooper: cabecalho.getCooperativaSelecionada(),
                cdtarifa: pacote.cdtarifa,
                qtdsms: pacote.qtdsms,
                perdesconto: pacote.perdesconto,
                redirect: "script_ajax"
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            },
            beforeSend: function() {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function(response) {
                hideMsgAguardo();
                if(response.erro == undefined) {
                    atualizarValoresTarifa(response.vlsms, response.vlsmsad, response.vlpacote);
                } else {
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + response.erro + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
                }
            }
        });
   }

   FormularioPacote.onClick_Voltar = function() {
        FormularioPacote.inicializar();
   }

   FormularioPacote.inicializar = function() {
        estadoInicial();
        $('input[type="text"],select', '#frmOpcaoI').limpaFormulario();
   }

   var atualizarValoresTarifa = function(valorSms, valorSmsAdicional, valorPacote) {
        $("#frmOpcaoI #vlsms").val(valorSms);
        $("#frmOpcaoI #vlsmsad").val(valorSmsAdicional);
        $("#frmOpcaoI #vlpacote").val(valorPacote);
   }

   this.toDictionary = function() {
       var values = {};
       $.each(getFormulario().serializeArray(), function (i, field) {
           values[field.name] = field.value;
       });
       return values;
   }
}

// seletores
function estadoInicial() {

    cabecalho.inicializar();

	$('#divTela').fadeTo(0,0.1);

	fechaRotina( $('#divRotina') );

    // Limpa formularios
    cTodosCabecalho.limpaFormulario();
    // habilita foco no formulário inicial
    highlightObjFocus($('#frmCab'));

	$('#nmrescop','#frmFiltros').val(0);

    cDtiniofe.val("");
    cDtiniofe.datepicker('disable');
    cDtfimofe.val("");
    cDtfimofe.datepicker('disable');
    /*
    cddopcao = "M";
    cCddopcao.val(cddopcao);
   */

    Cabecalho.inicializarComponenteOpcao($('#cddopcao', '#frmCab')[0]);

    controlaLayout();

	removeOpacidade('divTela');
	$('#cddopcao', '#frmCab').focus();

	return false;

}

function controlaLayout() {

	cCamposAltera= $('#nmrescop,#dtiniope,#dtfimope','#frmFiltros');

	$('#frmOpcaoO').css({'display':'none'});
    $('#frmOpcaoM').css({'display':'none'});
    $('#frmOpcaoP').css({'display':'none'});
    $('#frmOpcaoZ').css({'display':'none'});
    $('#frmOpcaoI').css({'display':'none'});
    $('#frmFiltroGrid').css({'display':'none'});
    $('#divGrid').css({'display':'none'});
	formataCabecalho();

	layoutPadrao();
	return false;
}

function formataCabecalho() {

    // Cabeçalho
    $('#cddopcao', '#' + frmCab).focus();

    var btnOK = $('#btnOK','#frmCab');

	rCddopcao.addClass('rotulo').css({'width':'68px'});
	cCddopcao.css({'width':'330px'});

    rNmrescop.css({'padding-left':'10px'});
	cNmrescop.addClass('rotulo').css('width','130px');

    cTodosCabecalho.habilitaCampo();
    return false;
}

function FormatOpcaoO(){

    $("#frmOpcaoO").css({'display':'block'});
    rFlofesms.addClass('rotulo-linha').css({'padding-left':'5px'});
    cFlofesms.addClass('checkbox').css({'margin':'0px'});
    cFlofesms.addClass('checkbox').css({'margin-top':'3px'});

    rDtiniofe.addClass('rotulo').css({'width':'100px'});
    rDtfimofe.addClass('rotulo-linha').css({'width':'35px','text-align': 'center','padding-left':'60px'});

    cDtiniofe.addClass('campo').css({'width':'70px'}).setMask("STRING","ZZ/ZZ/ZZZZ","/","");
    cDtfimofe.addClass('campo').css({'width':'70px'}).setMask("STRING","ZZ/ZZ/ZZZZ","/","");

    cDsmensag.addClass('campo').css({'width':'670px','height':'98px','float':'left','margin-top':'10px', 'margin-left':'10px'});
    cDsmensag.attr('maxlength', '4000');

    // Validar data ao sair do campo
    cDtiniofe.unbind('blur').bind('blur', function() {
      if (!validarData(cDtiniofe.val())) {
          showError("error","Data de inicio inv&aacute;lida.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtiniofe.focus();");
          return false;
      }

    });

    /*Validar data ao sair do campo */
    cDtfimofe.unbind('blur').bind('blur', function() {
      if (!validarData(cDtfimofe.val())) {
          showError("error","Data de fim inv&aacute;lida.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtfimofe.focus();");
          return false;
      }

    });

    layoutPadrao();
}

function FormatOpcaoM(){

    $("#frmOpcaoM").css({'display':'block'});

    rFllindig.addClass('rotulo-linha').css({'padding-left':'5px'});
    cFllindig.addClass('checkbox').css({'margin':'0px'});

    cTodosTextarea = $('textarea', '#frmOpcaoM');
    cTodosTextarea.addClass('campo').css({'width':'95%','height':'50px','margin':'10px'});
    //cTodosTextarea.attr('maxlength', '145');
    return false;
}

function FormatOpcaoP(){

    $("#frmOpcaoP").css({'display':'block'});
    rNrdialau.addClass('rotulo').css({'padding-rigth':'5px','font-weight':'normal'});
    cNrdialau.addClass('campo').addClass('inteiro').css({'width':'35px','text-align':'right'});
    cNrdialau.attr('maxlength', '3').setMask("INTEGER", "zz9", ".", "");

    cTodosTextarea = $('textarea', '#frmOpcaoP');
    cTodosTextarea.addClass('campo').css({'width':'95%','height':'100px','margin':'10px'});//.setMask("STRING","4000","*","");
    cTodosTextarea.attr('maxlength', '4000');

    layoutPadrao();
    return false;
}

function FormatOpcaoZ(){

    $("#frmOpcaoZ").css({'display':'block'});

    var divRegistro = $('div.divRegistros', '#divLotes');
    var tabela = $('table', divRegistro);

    tabela.zebraTabela(0);

    $('#divLotes').css({'width': '80%'});
    divRegistro.css({'height':'280px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '75px';
    arrayLargura[1] = '200px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

    $('tbody > tr', tabela).each(function () {
        if ($(this).hasClass('corSelecao')) {
            $(this).focus();
        }
    });

    // Centralizar a div
    var larguraRotina = $("#divOpcaoZ").innerWidth();
    var larguraObjeto = $('#divLotes').innerWidth();

    var left = larguraRotina - larguraObjeto;
    left = Math.floor(left / 2);

    $('#divLotes').css('margin-left', left.toString());
    $('#divLotes').css('margin-bottom', '10px');

    layoutPadrao();
}

function formataOpcaoI() {
    formulario.formatar();
}

function formataOpcaoA() {
    filtroGridPacotes.exibir();
}

function formataOpcaoC() {
    filtroGridPacotes.exibir();
}

function LiberaCampos() {

    /*
    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    } */

    cabecalho.desabilitarTodosComponentes();

    switch (cabecalho.getOpcaoSelecionada())
    {
        case 'A':
            formataOpcaoA();
            break;
        case 'C':
            formataOpcaoC();
            break;
        case 'I':
            formataOpcaoI();
            break;
        case 'O':
            $('#frmOpcaoO').css({'display': 'block'});
            $('#divBotoes', '#frmOpcaoO').css({'display': 'block'});
            cDtiniofe.datepicker('enable');
            cDtfimofe.datepicker('enable');
            FormatOpcaoO();
            manterRotina($('#cddopcao', '#frmCab').val());
            break;
        case 'M':
            $('#divBotoes', '#frmOpcaoM').css({'display': 'block'});
            manterRotina('M');
            // Aguardar carregar as informaçoes para posteriormente formatar
            setTimeout(function () {
                FormatOpcaoM();
            }, 500);
            break;
        case 'P':
            $('#divBotoes', '#frmOpcaoP').css({'display': 'block'});
            manterRotina('P');

            // Aguardar carregar as informa�oes para posteriormente formatar
            setTimeout(function () {
                FormatOpcaoP();
            }, 500);
            break;
        case 'Z':
        	$('#divBotoes', '#frmOpcaoZ').css({'display': 'block'});
            $('div.divRegistros', '#divLotes').empty();
            manterRotina('Z');

            // Aguardar carregar as informa�oes para posteriormente formatar
            setTimeout(function () {
                FormatOpcaoZ();
            }, 500);
            break;
    }

	$('#divBotoes').css({'display': 'block'});

    return false;

}

function macara_data(data){

    var dt = data.val().replace('/','');

    if (dt.length > 4 ){
        if (dt.length == 5 ){
            dt = dt[0] + "/" + dt.substring(1,5);
        } else {
            dt = dt.substring(0,2) + '/' + dt.substring(2,6);
        }
    }

    data.val(dt);
    return false;
}


// Validar data
function validarData(data){
    /*nao validar data nula */
    if (data == ''){
      return true;
    }

    var valido = false;
    var dia = data.split("/")[0];
    var mes = data.split("/")[1];
    var ano = data.split("/")[2];
    var MyData = new Date(ano, mes-1, dia);

    if((MyData.getMonth()+1 != mes)|| (MyData.getDate() != dia)||  (MyData.getFullYear() != ano))
        valido = false;
      else
        valido = true;
    return valido;
  }

// Função para buscar anotações do associado
function buscaAnotacoes() {
	// Mostra mensagem de aguardo
	showMsgAguardo("Aguarde, carregando anota&ccedil;&otilde;es ...");
	
	// Carrega dados da conta através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/atenda/busca_anotacoes.php",
		data: {
			nrdconta: nrdconta,
			redirect: "html_ajax" // Tipo de retorno do ajax
		},
		error: function(objAjax,responseError,objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Ayllos","blockBackground(parseInt($('#divAnotacoes').css('z-index')))");
		},
		success: function(response) {
			$("#divListaAnotacoes").html(response);
}
	});
}

function manterRotina(cdopcao) {

    var dsaguardo = '';
    var dsmensag  = '';
    var mensagens 	= [];
    var lotesReenvio = [];
    hideMsgAguardo();
    var cdcoptel = $('#nmrescop','#frmCab').val();

    if (cdopcao == 'GO')
	{
        dsaguardo = 'Aguarde, gravando dados...';
        showMsgAguardo(dsaguardo);
        var dtiniofe = cDtiniofe.val();
        var dtfimofe = cDtfimofe.val();
        mensagens.push({ dsmensagem: "<![CDATA["+ cDsmensag.val() + "]]>"});
        var flofesms = $('#flofesms','#frmOpcaoO').is(':checked') ? 1 : 0;
        var flgenvia_sms = $('#flgenvia_sms','#frmOpcaoO').is(':checked') ? 1 : 0;
    }

    // Gravar opcao Manter mensagem
	if (cdopcao == 'GM')
	{
        dsaguardo = 'Aguarde, gravando dados...';
        showMsgAguardo(dsaguardo);
        var fllindig    = $('#fllindig','#frmOpcaoM').is(':checked') ? 1 : 0;

		// Gera um objeto com o conteúdo das mensagens na tela
		$("textarea","#divMensagens").each(function() {

				mensagens.push({
						  cdtipo_mensagem: $(this).attr("cdtipo_mensagem"),
						  dsmensagem: $(this).val()
				});

		});
	}

    // Gravar opcao P - Cadastrar Parametro
	if (cdopcao == 'GP')
	{
        dsaguardo = 'Aguarde, gravando dados...';
        showMsgAguardo(dsaguardo);
        var nrdialau    = cNrdialau.val();
        
		// Gera um objeto com o conteúdo das mensagens na tela
		$("textarea","#divMensagensP").each(function() {

				mensagens.push({
						  cdtipo_mensagem: $(this).attr("cdtipo_mensagem"),
						  dsmensagem: "<![CDATA["+ $(this).val() + "]]>"
				});

		});
	}

    // Gravar opcao RZ - Reenviar Zendia
	if (cdopcao == 'RZ') {
        dsaguardo = 'Aguarde, gravando dados...';
        showMsgAguardo(dsaguardo);

		// Gera um objeto com o conteúdo das mensagens na tela
		$("input","#divLotes").each(function() {

            if ($(this).is(':checked'))	{
				lotesReenvio.push({idlote_sms: $(this).val()});
			}
		});

	}

    $.ajax({
        type: 'POST',
        async: true,
        url: UrlSite + 'telas/cadsms/manter_rotina.php',
        data: {
            cddopcao: cdopcao,
            cdcoptel: cdcoptel,
            flofesms: flofesms,
            dtiniofe: dtiniofe,
            dtfimofe: dtfimofe,
            dsmensag: dsmensag,
            fllindig: fllindig,
            flgenvia_sms: flgenvia_sms,
            nrdialau: nrdialau,
		    json_mensagens	: JSON.stringify(mensagens),
            json_lotesReenv : JSON.stringify(lotesReenvio),
            redirect: 'script_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
        },
        success: function(response) {
            try {
                eval(response);
                return false;
            } catch (error) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'estadoInicial();');
            }
        }
    });
    return false;
}

function confirmaOpcaoO() {

    if (cDtiniofe.val() == ""){
        showError("error","Data de inicio do periodo deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtiniofe.focus();");
        return false;
    }

    if (cDtfimofe.val() == "" ){
        showError("error","Data de final do periodo deve ser informada.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtfimofe.focus();");
        return false;
    }

    //Validar periodo
    var dia = cDtiniofe.val().split("/")[0];
    var mes = cDtiniofe.val().split("/")[1];
    var ano = cDtiniofe.val().split("/")[2];
    var DataIni = new Date(ano, mes-1, dia);

    var dia = cDtfimofe.val().split("/")[0];
    var mes = cDtfimofe.val().split("/")[1];
    var ano = cDtfimofe.val().split("/")[2];
    var DatFim = new Date(ano, mes-1, dia);

    if (DataIni > DatFim){
        showError("error","Data de inicio do periodo deve ser menor ou igual a data final.","Alerta - Ayllos","blockBackground(); unblockBackground(); cDtfimofe.focus();");
        return false;
    }

    var dsconfir = "";

    if (cNmrescop.val() == 0){
        dsconfir = ', dados ser&atilde;o replicados para todas as cooperativas';
    }

    showConfirmacao('Confirma a grava&ccedil;&atilde;o dos parametros' + dsconfir + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'GO\');', '', 'sim.gif', 'nao.gif');
}

function confirmaOpcaoM() {

    var dsconfir = "";

    if (cNmrescop.val() == 0){
        dsconfir = ', dados ser&atilde;o replicados para todas as cooperativas';
    }

    showConfirmacao('Confirma a grava&ccedil;&atilde;o dos parametros' + dsconfir + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'GM\');', '', 'sim.gif', 'nao.gif');
}

function confirmaOpcaoP() {

    var dsconfir = "";

    if (cNmrescop.val() == 0){
        dsconfir = ', dados ser&atilde;o replicados para todas as cooperativas';
    }

    showConfirmacao('Confirma a grava&ccedil;&atilde;o dos parametros' + dsconfir + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'GP\');', '', 'sim.gif', 'nao.gif');
}

function confirmaOpcaoZ() {

    showConfirmacao('Confirma reenvio?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina(\'RZ\');', '', 'sim.gif', 'nao.gif');
}
/*
function ajustarCentraliCadsms() {
	var x = $.browser.msie ? $(window).innerWidth() : $("body").offset().width;
	x = x - 178;
	$('#divRotina').css({'width': x+'px'});
	$('#divRotina').centralizaRotinaH();
	return false;
}*/

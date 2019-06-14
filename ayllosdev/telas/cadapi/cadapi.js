/*!
 * FONTE        : cadapi.js
 * CRIAÇÃO      : André Clemer - Supero
 * DATA CRIAÇÃO : 05/02/2019
 * OBJETIVO     : Biblioteca de funções da tela CADAPI
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */

var cddopcao = '';

var rCddopcao, cCddopcao, cTodosCabecalho;

var cabecalho,
    form,
    grid,
    popup;

var frmCab = '#frmCab';

var arr_dsfinalidade = [];

$(document).ready(function () {

    cabecalho = new Cabecalho();
    grid = new Grid();
    popup = new Popup();
    form = new Form();

    // cabecalho
    cTodosCabecalho = $('input[type="text"],select', frmCab);
    rCddopcao = $('label[for="cddopcao"]', frmCab);
    cCddopcao = $('#cddopcao', frmCab);

    estadoInicial();
});

function estadoInicial() {

    cabecalho.inicializar();

    $('#divTela').fadeTo(0, 0.1);

    fechaRotina($('#divRotina'));

    // Limpa formularios
    cTodosCabecalho.limpaFormulario();
    form.limpaFormulario();
    grid.esconder();

    // habilita foco no formulário inicial
    highlightObjFocus($(frmCab));

    cabecalho.inicializarComponenteOpcao($('#cddopcao', frmCab)[0]);

    controlaLayout();

    removeOpacidade('divTela');
    $('#cddopcao', frmCab).focus();

    return false;
}

function controlaLayout() {

    cabecalho.formatar();

    form.esconder();

    layoutPadrao();

    // Opção
    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#btnOK', '#frmCab').click();
            return false;
        }
    });
    
    // Botão OK da Opção
    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function (e) {
        // se pressionou TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            // libera os campos para continuar
            LiberaCampos();
            return false;
        }
    });

    // Produto
    /*$('#cdproduto', '#frmCadapi').unbind('change').bind('change', function (e) {
        if ($('#cdproduto', '#frmCadapi').val() != '') {
            form.onClick_Prosseguir();
        }
    });*/

    $('#cdproduto', '#frmCadapi').unbind('keypress').bind('keypress', function (e) {
        // se pressionou TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            // se produto esta selecionado
            if ($('#cdproduto', '#frmCadapi').val() != '') {
                form.onClick_ProsseguirServico();
            }
        }
    });
	
	$('#servico_api', '#frmCadServico').unbind('keypress').bind('keypress', function (e) {
        // se pressionou TAB ou ENTER
        if (e.keyCode == 9 || e.keyCode == 13) {
            // se produto esta selecionado
            if ($('#servico_api', '#frmCadServico').val() != '') {
                form.onClick_Prosseguir();
            }
        }
    })

    return false;
}

function LiberaCampos() {

    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/cadapi/validar_permissao.php",
        data: {
            cddopcao: cabecalho.getOpcaoSelecionada(),
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept + ".", "Alerta - Aimaro", "$('#cddopcao',frmCab).focus()");
        },
        beforeSend: function () {
            showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
        },
        success: function (response) {
            if (response.substr(0, 14) == 'hideMsgAguardo') {
                eval(response);
            } else {
                cabecalho.desabilitarTodosComponentes();
                form.inicializar();
                hideMsgAguardo();
            }
        }
    });

    return false;
}

function Cabecalho() {

    // private
    var getTodosComponentes = function () {
        return $('input[type="text"],select', frmCab);
    }

    var getComponenteOpcoes = function () {
        return $('#cddopcao', frmCab);
    }

    // public
    this.formatar = function () {

        // Cabeçalho
        $('#cddopcao', frmCab).focus();

        var btnOK = $('#btnOK', frmCab);

        cTodosCabecalho.habilitaCampo();
        return false;
    }

    this.onChangeOpcao = function (componenteOpcoes) {
        this.inicializarComponenteOpcao(componenteOpcoes);
    }

    this.inicializarComponenteOpcao = function (componenteOpcoes) {
        //
    }

    this.getOpcaoSelecionada = function () {
        return getComponenteOpcoes().val();
    }

    this.desabilitarTodosComponentes = function () {
        getTodosComponentes().desabilitaCampo();
    }

    this.getCooperativaSelecionada = function () {
        return getComponenteCooperativas().val();
    }

    this.inicializar = function () {
        this.inicializarComponenteOpcao(getComponenteOpcoes());
    }

}

var Form = function () {
    this.getFormulario = function (){
        return $('#frmCadapi');
    };
	
	this.getFormularioServico = function (){
        return $('#frmCadServico');
    };

    this.getComponentes = function (){
        return form.getFormulario().find('input[type="text"],input[type="hidden"],select');
    };
	
	this.getComponentesServico = function (){
        return form.getFormularioServico().find('input[type="text"],input[type="hidden"],select');
    };

    this.limpaFormulario = function () {
        form.getComponentes().limpaFormulario();
        form.getComponentesServico().limpaFormulario();
    }

    this.inicializar = function (){
        form.getFormulario().show();
        form.getFormularioServico().hide();
        form.getComponentes().habilitaCampo();
        form.getComponentesServico().habilitaCampo();
        form.getFormulario().find('#divBotoes').show();
        form.getFormularioServico().find('#divBotoes').show();
        highlightObjFocus(form.getFormulario());
        form.getFormulario().find('#cdproduto').focus();
    }

    this.esconder = function (){
        form.getFormulario().hide();
        form.getFormularioServico().hide();
    }

    // Prosseguir a partir do form
    this.onClick_Prosseguir = function () {
        if (!form.getFormularioServico().find('#servico_api').val().trim()) {
            showError("error", "O campo Servico API &eacute; obrigat&oacute;rio.", "Alerta - Aimaro", "$('#servico_api','#frmCadapi').focus()");
            return false;
        }
        arr_dsfinalidade = [];
        grid.carregar(1);
    }
	
	// Prosseguir a partir do form
    this.onClick_ProsseguirServico = function () {
        if (!form.getFormulario().find('#cdproduto').val().trim()) {
            showError("error", "O campo Produto &eacute; obrigat&oacute;rio.", "Alerta - Aimaro", "$('#cdproduto','#frmCadapi').focus()");
            return false;
        }
        arr_dsfinalidade = [];
        grid.carregarServicos();
		form.getFormularioServico().find('#servico_api').focus();
    }

    this.controlaPesquisa = function (tipo) {

        if (tipo == 'P') {
            // Definicao dos filtros
            var filtros = "Codigo;cdproduto;;;;N;|Descricao;dsproduto;200px;S;;;";

            // Campos que serao exibidos na tela
            var colunas = 'Codigo;cdproduto;20%;center|Descricao;dsproduto;80%;left';

            // Exibir a pesquisa
            mostraPesquisa("TELA_CADAPI",
                           "CONSULTA_PRODUTOS",
                           "Produtos",
                           "30",
                           filtros,
                           colunas,
                           '',
                           ';$(\'#dsproduto\',\'#frmCadapi\').val();',
                           'frmCadapi'
                           );
        }

        return false;
    }
};

function Grid() {

    // private
    var registroSelecionado;
    var atualizarAlcada = 0;

    var selecionarRegistro = function (Id) {
        registroSelecionado = Id;
    }

    var totalRegistros = function (divRegistro) {
        return $('table > tbody > tr', divRegistro).size();
    }

    var existeRegistros = function (divRegistro) {
        return totalRegistros(divRegistro) > 0;
    }

    var selecionarPrimeiroRegistro = function (divRegistro) {

        if (existeRegistros(divRegistro)) {
            var primeiroRegistro = getTodosRegistros()[0];
            selecionarRegistro(primeiroRegistro.id);
        }
    }

    var getTodosRegistros = function () {
        return $('#divGrid > .divRegistros > table > tbody > tr');
    }

    var formatarBotoes = function () {

        // cabecalho.getOpcaoSelecionada()
    }

    var bindRegistrosGrid = function (divRegistro) {
        $('table > tbody > tr', divRegistro).click(function () {
            grid.onRegistroClick(this);
        });
    }

    // public
    this.setAtualizarAlcada = function (flregra) {
        atualizarAlcada = flregra;
    }

    this.getAtualizarAlcada = function () {
        return atualizarAlcada;
    }

    this.getRegistroSelecionado = function () {
        return registroSelecionado;
    }

    this.onRegistroClick = function (registro) {
        selecionarRegistro(registro.id);
    }

    this.formatar = function () {

        var divRegistro = $('div.divRegistros', '#divGrid');
        var tabela = $('table', divRegistro);

        var ordemInicial = new Array();

        var arrayLargura = ['25px'];
        var arrayAlinha = ['center', 'left'];

        formatarBotoes();

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');

        $('#divPesquisaRodape', '#divGrid').formataRodapePesquisa();

        $('input[type="checkbox"]', divRegistro).unbind('change').bind('change', function () {
            var linhaAtual = $(this).closest('tr');
            if (linhaAtual.hasClass('unsaved')) {
                var key = linhaAtual.attr('id');
                    key = key.split('_')[1];

                arr_dsfinalidade[key].idsituacao = $(this).prop('checked') ? 1 : 0;
            }
        });

        if (existeRegistros(divRegistro)) {
            bindRegistrosGrid(divRegistro);
            selecionarPrimeiroRegistro(divRegistro);

            $('.headerSort').click(function () {
                bindRegistrosGrid(divRegistro);
            })
        }
    }
	
	this.carregarServicos = function () {
		form.getFormularioServico().show();
		grid.formatar();
		form.getComponentes().desabilitaCampo();
		form.getFormulario().find('#divBotoes').hide();
	}

    this.carregar = function (recarregarFinalidades) {
		
		var lista_finalidades = [];
        var len = arr_dsfinalidade.length;

        for (var i=0; i < len; ++i){
            lista_finalidades.push(arr_dsfinalidade[i].cdfinalidade + '#' +
                                   arr_dsfinalidade[i].dsfinalidade + '#' +
                                   arr_dsfinalidade[i].idsituacao
                                );
        }
		
		var linhas = $('#divGrid > .divRegistros > table > tbody > tr'),
            i = 0,
            len = linhas.length,
            dados = [];
        
        for (; i < len; ++i) {
            var linha = $(linhas[i]),
                cdfinalidade = linha.find('#cdfinalidade').val(),
                dsfinalidade = linha.find('#dsfinalidade').val(),
                idsituacao = (cabecalho.getOpcaoSelecionada() == "E" ? 2 : (linha.find('#idsituacao').is(':checked') ? 1 : 0));
            
            var registro = [cdfinalidade,dsfinalidade,idsituacao].join('#');
            dados.push(registro);
        }
		
		var len = arr_dsfinalidade.length;
		if (len>0){
			dados.push([arr_dsfinalidade[len-1].cdfinalidade,arr_dsfinalidade[len-1].dsfinalidade,arr_dsfinalidade[len-1].idsituacao].join('#'));
		}
		
		console.log(dados);

        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/cadapi/consultar_finalidades.php",
            data: {
                cddopcao: cabecalho.getOpcaoSelecionada(),
                idservico_api: form.getFormularioServico().find('#servico_api').val(),
                arr_dsfinalidade: dados.join('|'),
				carregarFinalidades: recarregarFinalidades,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept + ".", "Alerta - Aimaro", "$('#cddopcao',frmCab).focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                } else {
                    $('#divGrid').html(response);
                    $('#divGrid').css({
                        'display': 'block'
                    });
                    grid.formatar();
                    form.getComponentesServico().desabilitaCampo();
					form.getFormularioServico().find('#divBotoes').hide();
                }
            }
        });
    }

    this.onClick_Voltar = function () {
        $('#divGrid').hide();
        form.inicializar();
    }

    // Prosseguir da grid
    this.onClick_Prosseguir = function () {
        this.carregar();
    };

    this.onClick_Remover = function () {
        var divRegistro = '#divGrid > .divRegistros';

        $('table > tbody > tr.corSelecao', divRegistro).remove();

        $('table > tbody > tr', divRegistro).each(function (i) {
            $(this).unbind('click').bind('click', function () {
                $('table', divRegistro).zebraTabela(i);
            });
        });
    }

    this.onClick_Gravar = function () {
        var linhas = $('#divGrid > .divRegistros > table > tbody > tr'),
            i = 0,
            len = linhas.length,
            dados = [];
        
        for (; i < len; ++i) {
            var linha = $(linhas[i]),
                cdfinalidade = linha.find('#cdfinalidade').val(),
                dsfinalidade = linha.find('#dsfinalidade').val(),
                idsituacao = (cabecalho.getOpcaoSelecionada() == "E" ? 2 : (linha.find('#idsituacao').is(':checked') ? 1 : 0));
            
            var registro = [cdfinalidade,dsfinalidade,idsituacao].join('#');
            dados.push(registro);
        }

        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/cadapi/gravar_finalidades.php",
            data: {
                cddopcao: cabecalho.getOpcaoSelecionada(),
                idservico_api: form.getFormularioServico().find('#servico_api').val(),
                ls_finalidades: dados.join('|'),
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept + ".", "Alerta - Aimaro", "$('#cddopcao',frmCab).focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                eval(response);
            }
        });


    }

    this.esconder = function (){
        $('#divGrid').hide();
    }
}

function Popup() {

    // private
    var formatar = function () {
        $('#divRotina').css('width', '700px').centralizaRotinaH();
        
        popup.getFormulario().find('#dsfinalidade').unbind('keypress').bind('keypress', function (e) {
            // se pressionou TAB ou ENTER
            if (e.keyCode == 9 || e.keyCode == 13) {
                //e.preventDefault();
                // se produto esta selecionado
                popup.getFormulario().find('#btConfirmar').click();
                return false;
            }
        });

        popup.getFormulario().find('#dsfinalidade').focus();
    }

    // public
    this.getFormulario = function () {
        return $('#frmFinalidade');
    }

    var getComponenteBotaoAlterar = function () {
        return $("#btPopupAlterar");
    }

    var desabilitarCampos = function () {
        getTodosComponentes().desabilitaCampo();
    }

    var getTodosComponentes = function () {
        return $('input[type="text"],select', '#frmPacote');
    }

    // public
    this.exibir = function (modoAlteracao) {
        // alteração e sem seleção
        if (modoAlteracao && !$('.divRegistros > table tr.corSelecao').length) {
            showError("error", "Voc&ecirc; deve selecionar um registro para edi&ccedil;&atilde;o", "Alerta - Aimaro", "");
            return;
        }
        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/cadapi/popup_finalidade.php",
            data: {
                cddopcao: cabecalho.getOpcaoSelecionada(),
                cdproduto: form.getFormulario().find('#cdproduto').val(),
                modoAlteracao: modoAlteracao,
                redirect: "script_ajax" // Tipo de retorno do ajax
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + objExcept + ".", "Alerta - Aimaro", "$('#cddopcao',frmCab).focus()");
            },
            beforeSend: function () {
                showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");
            },
            success: function (response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                } else {
                    $('#divRotina').html(response);
                    if (modoAlteracao){
                        var linhaAtual = $('.divRegistros > table tr.corSelecao');
                        popup.getFormulario().find('#dsfinalidade').val(linhaAtual.find('#dsfinalidade').val());
                    }
                    hideMsgAguardo();
                    exibeRotina($('#divRotina'));
                    bloqueiaFundo($('#divRotina'));
                    formatar();
                }
            }
        });
    }

    this.isValid = function() {

        var obj = {
            isValid: true,
            Message: '',
            Field: null
        }

        if(popup.getFormulario().find('#dsfinalidade').val().trim() == '') {
            obj = {
                isValid: false,
                Message: "Campo de descri&ccedil;&atilde;o da finalidade deve ser informado.",
                Field: '#dsfinalidade'
            };
            return obj;
        }

        return obj;
    }

    this.onClick_Voltar = function () {
        fechaRotina($('#divRotina'));
    }

    this.onClick_Confirmar = function (modoAlteracao, recarregarFinalidades){
        var validator = popup.isValid();

        if(!validator.isValid) {
            showError("error", validator.Message, "Alerta - Aimaro", "bloqueiaFundo($('#divRotina'));popup.getFormulario().find('" + validator.Field + "').focus()");
            return;
        }

        var dsfinalidade = popup.getFormulario().find('#dsfinalidade').val();
            
        // alteração
        if (modoAlteracao) {
            var linhaAtual = $('.divRegistros > table tr.corSelecao');
            linhaAtual.find('#dsfinalidade').val(dsfinalidade);
            linhaAtual.find('td:nth-child(2)').html(dsfinalidade);

            if (linhaAtual.hasClass('unsaved')) {
                var key = linhaAtual.attr('id');
                    key = key.split('_')[1];

                arr_dsfinalidade[key].dsfinalidade = dsfinalidade;
            }
			
			
			console.log(arr_dsfinalidade);
        // inclusão
        } else {
            arr_dsfinalidade.push({
                cdfinalidade: 0,//arr_dsfinalidade.length,
                dsfinalidade: dsfinalidade,
                idsituacao: 1
            });

            grid.carregar(recarregarFinalidades);
            /*var row = '<tr class="corSelecao">' +
                        '<td width="25" style="text-align: center;">'+
                        '    <input type="hidden" id="cdfinalidade" name="cdfinalidade" value="" />'+
                        '    <input type="hidden" id="dsfinalidade" name="dsfinalidade" value="'+dsfinalidade+'" />'+
                        '    <input type="checkbox" id="idsituacao" name="idsituacao" value="1" checked />'+
                        '</td>'+
                        '<td style="text-align: left;">'+dsfinalidade+'</td>' +
                    '</tr>';

            var $row = $(row);

            $('#divGrid > .divRegistros > table > tbody').append($row);

            $('#divGrid > .divRegistros > table').zebraTabela();*/
        }

        hideMsgAguardo();

        popup.onClick_Voltar();
    }

}
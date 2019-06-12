/*!
 * FONTE        : solpor.js
 * CRIAÇÃO      : Augusto - Supero
 * DATA CRIAÇÃO : 17/10/2018
 * OBJETIVO     : Biblioteca de funções da tela SOLPOR
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

var rCddopcao, cCddopcao, cTodosFiltro;

var cabecalho;
var filtro;
var fomulario;
var grid;
var paginaAtual;

var frmCab = 'frmCab';
var frmFiltro = 'frmFiltro';

$(document).ready(function () {

    cabecalho = new Cabecalho();
    filtro = new Filtro();
    grid = new Grid();

    // cabecalho
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    cCddopcao = $('#cddopcao', '#' + frmCab);

    estadoInicial();

});


function Cabecalho() {

    this.getOpcaoSelecionada = function () {
        return this.getComponenteOpcoes().val();
    }

    this.desabilitarTodosComponentes = function () {
        this.getTodosComponentes().desabilitaCampo();
    }

    this.getTodosComponentes = function () {
        return $('input[type="text"],select', '#' + frmCab);
    }

    this.getComponenteOpcoes = function () {
        return $('#cddopcao', '#' + frmCab);
    }

    this.habilitaCampos = function () {
        this.getTodosComponentes().habilitaCampo();
    }

    this.inicializar = function () {
        this.getTodosComponentes().limpaFormulario();
        this.habilitaCampos();
        this.getComponenteOpcoes().focus();
        this.getComponenteOpcoes().unbind('keypress').bind('keypress', function(e) {
		if ( divError.css('display') == 'block' ) { return false; }
		if ( e.keyCode == 13 ) {
			LiberaCampos();
			return false;
		}
	});	
    }
}

function Filtro() {

    this.getTodosComponentes = function () {
        return $('input[type="text"],input[type="checkbox"],select', '#' + frmFiltro);
    }

    this.getCooperativa = function () {
        return $('#cdcooper', '#' + frmFiltro).val();
    }

    this.getCooperativaSelecionada = function () {
        return $('#nmrescop', '#' + frmFiltro).val();
    }

    this.getConta = function () {
        return $('#nrdconta', '#' + frmFiltro).val();
    }

    this.getPA = function () {
        return $('#cdagenci', '#' + frmFiltro).val();
    }

    this.getDataSolicitacaoInicial = function () {
        return $('#dataSolicitacaoInicio', '#' + frmFiltro).val();
    }

    this.getDataSolicitacaoFinal = function () {
        return $('#dataSolicitacaoFim', '#' + frmFiltro).val();
    }

    this.getDataRetornoInicial = function () {
        return $('#dataRetornoInicio', '#' + frmFiltro).val();
    }

    this.getDataRetornoFinal = function () {
        return $('#dataRetornoFim', '#' + frmFiltro).val();
    }

    this.getSituacao = function () {
        return $('#situacaoPortabilidade', '#' + frmFiltro).val();
    }

    this.getNUPortabilidade = function () {
        return $('#nuPortabilidade', '#' + frmFiltro).val();
    }

    this.habilitaCampos = function () {
        this.getTodosComponentes().habilitaCampo();
        if (this.getCooperativa() != 3) {
            $("#nmrescop", '#' + frmFiltro).desabilitaCampo();
        }
    }

    this.inicializar = function () {
        this.habilitaCampos();
        this.inicializarComponentes();
    }

    this.desabilitarTodosComponentes = function () {
        this.getTodosComponentes().desabilitaCampo();
        $("#lupaPA", '#' + frmFiltro).unbind('click');
        $("#lupaAss", '#' + frmFiltro).unbind('click');
        $(".data", '#' + frmFiltro).datepicker('disable');
    }

    this.formatar = function (cddopcao) {
        filtro.inicializar();

        $('#divFiltro').css({
            'display': 'block'
        });

        $('#divBotoes').css({
            'display': 'block'
        });

        $('#btContinuar', '#divBotoes').unbind('click').bind('click', function (e) {
            grid.carregar(cddopcao, 1);
        });


        $('#btVoltar', '#divBotoes').unbind('click').bind('click', function (e) {
            estadoInicial();
        });
        
        $('#btContinuar', '#divBotoes').css({
            'display': 'inline-block'
        });

        $("select:not([disabled]),input[type='text']:not([disabled])", "#frmFiltro").first().focus();
    }

    this.inicializarComponentes = function () {
        $('#lupaPA', '#' + frmFiltro).unbind('click').bind('click', function(e) {
            bo			= 'b1wgen0059.p';
            procedure	= 'busca_pac';
            titulo      = 'Agencia PA';
            qtReg		= '20';					
            filtrosPesq	= 'Cod. PA;cdagenci;30px;S;0;;codigo;|Agencia PA;nmresage;200px;S;;;descricao;';
            colunas 	= 'Codigo;cdagepac;20%;right|Descricao;dsagepac;80%;left';
            mostraPesquisa(bo,procedure,titulo,qtReg,filtrosPesq,colunas,'','','',$("#nmrescop", '#' + frmFiltro).val());
        });

        $('#lupaAss', '#' + frmFiltro).unbind('click').bind('click', function(e) {
            $('#cdcooper', '#frmPesquisaAssociado').remove();
            mostraPesquisaAssociado('nrdconta',frmFiltro,'','',$("#nmrescop", '#' + frmFiltro).val())
        });

        $("#nmrescop", '#' + frmFiltro).unbind('change').bind('change', function(e) {
            $("#cdagenci", '#' + frmFiltro).val('');
            $("#nrdconta", '#' + frmFiltro).val('');
        });

        $('.data').datepicker({
            dateFormat: "dd/mm/yy",
            showOn: "button",
            buttonImage: "../../imagens/geral/btn_calendario.gif",
            buttonImageOnly: true,
            buttonText: ""
        });
        $(".data", '#' + frmFiltro).datepicker('enable');
        $("#nrdconta", "#frmFiltro").bind("keyup", function (e) {
            if (!$(this).setMaskOnKeyUp("INTEGER", "zzzz.zzz-z", "", e)) {
                return false;
            }
        });
        $("#nrdconta", "#frmFiltro").bind("blur", function () {
            if ($(this).val() == "") {
                return true;
    }
            if (!validaNroConta(retiraCaracteres($(this).val(), "0123456789", true))) {
                showError("error", "Conta/dv inv&aacute;lida.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus()");
                $("#nrdconta", "#frmFiltro").val("");
                return false;
            }

            return true;
        });
        layoutPadrao();
    }

    this.carregar = function (cddopcao) {
        showMsgAguardo('Aguarde, carregando...');
        $('#divFiltro').html('');
        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + 'telas/solpor/form_filtro.php',
            data: {
                cddopcao: cddopcao,
                redirect: 'script_ajax'
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
            },
            success: function (response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                } else {
                    $('#divFiltro').html(response);
                }
            }
        });
    }
}

function Grid() {

    this.formatar = function (cddopcao) {

        $('#btVoltar', '#divBotoes').unbind('click').bind('click', function (e) {
            grid.desabilitarGrid();
            filtro.formatar(cddopcao);
        });
        
        var divRegistro = $('div.divRegistros', '#divGrid');
        var tabela = $('table', divRegistro);
        divRegistro.css({
            'height': '280px'
        });

        var tabelaHeader = $('table > thead > tr > th', divRegistro);
        var fonteLinha = $('table > tbody > tr > td', divRegistro);

        tabelaHeader.css({
            'font-size': '11px'
        });
        fonteLinha.css({
            'font-size': '11px',
            'height': '28px'
        });

        $('#divListaSolicitacoes').css({
            'display': 'block'
        });

        $('#btContinuar', '#divBotoes').css({
            'display': 'none'
        });

        var ordemInicial = new Array();

		var arrayLargura = new Array();
		arrayLargura[0] = '25px';
		arrayLargura[1] = '137px';
		arrayLargura[2] = '95px';
		arrayLargura[3] = '67px';
        arrayLargura[4] = '70px';
        arrayLargura[5] = '67px';
        arrayLargura[6] = '150px';
        


		var arrayAlinha = new Array();
		arrayAlinha[0] = 'center';
		arrayAlinha[1] = 'center';
		arrayAlinha[2] = 'left';
		arrayAlinha[3] = 'center';
        arrayAlinha[4] = 'left';
        arrayAlinha[5] = 'center';
        arrayAlinha[6] = 'left';
        arrayAlinha[7] = 'center';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
    };

    this.desabilitarGrid = function() {
        $('#divListaSolicitacoes').html('');
        $('#btContinuar', '#divBotoes').css({
            'display': 'inline-block'
        });
    }

    this.reload = function () {
        this.carregar(cabecalho.getOpcaoSelecionada(), paginaAtual);
    }

    this.carregar = function (cddopcao, pagina) {
        var cdcooper = filtro.getCooperativaSelecionada();
        var nrdconta = normalizaNumero(filtro.getConta() || 0);
        var cdagenci = filtro.getPA();
        var dtsolicitacao_ini = filtro.getDataSolicitacaoInicial();
        var dtsolicitacao_fim = filtro.getDataSolicitacaoFinal();
        var dtretorno_ini = filtro.getDataRetornoInicial();
        var dtretorno_fim = filtro.getDataRetornoFinal();
        var idsituacao = filtro.getSituacao();
        var nuPortabilidade = filtro.getNUPortabilidade();

        paginaAtual = pagina;

        showMsgAguardo('Aguarde, carregando...');

        $('#divListaSolicitacoes').html('');
        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + 'telas/solpor/grid_solicitacoes.php',
            data: {
                cddopcao: cddopcao,
                cdcooper: cdcooper,
                nrdconta: nrdconta,
                cdagenci: cdagenci,
                dtsolicitacao_ini: dtsolicitacao_ini,
                dtsolicitacao_fim: dtsolicitacao_fim,
                dtretorno_ini: dtretorno_ini,
                dtretorno_fim: dtretorno_fim,
                idsituacao: idsituacao,
                nuPortabilidade: nuPortabilidade,
                pagina: pagina,
                redirect: 'script_ajax'
            },
            error: function (objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Aimaro', 'estadoInicial();');
            },
            success: function (response) {
                if (response.substr(0, 14) == 'hideMsgAguardo') {
                    eval(response);
                } else {
                    $('#divListaSolicitacoes').html(response);
                    filtro.desabilitarTodosComponentes();
                    grid.formatar(cddopcao);
                    hideMsgAguardo();
                }
            }
        });
    }
}

// seletores
function estadoInicial() {

    cabecalho.inicializar();

    $('#divTela').fadeTo(0, 0.1);

    fechaRotina($('#divRotina'));

    // habilita foco no formulário inicial
    highlightObjFocus($('#' + frmCab));

    $('#divFiltro').css({
        'display': 'none'
    });

    $('#divBotoes').css({
        'display': 'none'
    });

    $('#divListaSolicitacoes').css({
        'display': 'none'
    });

    removeOpacidade('divTela');

    layoutPadrao();

    return false;
}

function LiberaCampos() {
    filtro.carregar(cabecalho.getOpcaoSelecionada());
    return false;
}

function buscaDadosPA() {

	showMsgAguardo("Aguarde...");

    var cdagenci = $('#cdagenci','#' + frmFiltro).val();

    // Executa script de bloqueio através de ajax
	$.ajax({		
		type: "POST",
		url: UrlSite + "telas/cadpac/busca_dados.php", 
		data: {			
			cddopcao: 'C',
            cdagenci: normalizaNumero(cdagenci),
			redirect: "script_ajax"
		}, 
		error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
			}
		}
	});
}

function ajustarCentralizacao(item) {
    var x = $.browser.msie ? $(window).innerWidth() : $("body").offset().width;
    x = x - 178;
    item.css({ 'width': x + 'px' });
    item.centralizaRotinaH();
    return false;
}

function exibirDetalhe(dsrowid){
	showMsgAguardo("Aguarde, carregando ...");
    exibeRotina($('#divUsoGenerico'));

    var cddopcao = cabecalho.getOpcaoSelecionada();
    $('#divUsoGenerico').html('');
    $.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/solpor/detalhe_solicitacao.php",
		data: {
            dsrowid: dsrowid,
            cddopcao: cddopcao,
			redirect: "script_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
            if (response.substr(0, 14) == 'hideMsgAguardo') {
                eval(response);
            } else {
                $('#divUsoGenerico').html(response);
                hideMsgAguardo();
                bloqueiaFundo($('#divUsoGenerico'));
                ajustarCentralizacao($('#divUsoGenerico'));
            }
		}
	});

}
function validarAprovacaoPortabilidade(dsrowid) {
    showConfirmacao('Confirma a aprova&ccedil;&atilde;o da portabilidade?', 'Confirma&ccedil;&atilde;o - Aimaro', 'avaliarPortabilidade("2", "'+dsrowid+'", "")', '', 'sim.gif', 'nao.gif');
}
function avaliarPortabilidade(idsituacao, dsrowid, cdmotivo) {
     $.ajax({		
		type: "POST",
		url: UrlSite + "telas/solpor/manter_rotina.php", 
		data: {
            acao: 'avaliarPortabilidade',
            cddopcao: cabecalho.getOpcaoSelecionada(),
			idsituacao: idsituacao,
            dsrowid: dsrowid,
            cdmotivo: cdmotivo,
			redirect: "script_ajax"
		}, 
		error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
			}
		}
	});
}

function selecionarConta(item) {
    $(item).find('input[type="radio"]').attr('checked', 'checked');
}
function formatarGridContas() {
    var divRegistro = $('div.divRegistros', '#divContas');
    var tabela = $('table', divRegistro);
    divRegistro.css({
        'height': '100px' 
    });
    var tabelaHeader = $('table > thead > tr > th', divRegistro);
    var fonteLinha = $('table > tbody > tr > td', divRegistro);

    tabelaHeader.css({
        'font-size': '11px'
    });
    fonteLinha.css({
        'font-size': '11px'
    });

    $('#divListaSolicitacoes').css({
        'display': 'block'
    });

    $('#btContinuar', '#divBotoes').css({
        'display': 'none'
    });

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '20px';
    arrayLargura[1] = '105px';
    arrayLargura[2] = '55px';
    arrayLargura[3] = '85px';
    arrayLargura[4] = '125px';
    arrayLargura[5] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'left';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, '');
}
function direcionarPortabilidade(dsrowid, cdcooper, nrdconta) {
    $.ajax({		
		type: "POST",
		url: UrlSite + "telas/solpor/manter_rotina.php", 
		data: {
            acao: 'direcionarPortabilidade',
            cddopcao: cabecalho.getOpcaoSelecionada(),
			cdcooper: cdcooper,
            nrdconta: nrdconta,
            dsrowid: dsrowid,
			redirect: "script_ajax"
		}, 
		error: function(objAjax, responseError, objExcept) {
			hideMsgAguardo();
			showError("error","N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.","Alerta - Aimaro","blockBackground(parseInt($('#divTela').css('z-index')))");
		},
		success : function(response) {
			hideMsgAguardo();
			try { 
				eval(response);
				return false;
			} catch(error) {
				hideMsgAguardo();
				showError('error','N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.','Alerta - Aimaro','unblockBackground()');
			}
		}
	});
}
function validarDirecionamentoPortabilidade(dsrowid) {    
    var identificador = $('input[name="identificador"]:checked', '#frmDireciona').val();
    if (typeof identificador === "undefined" || identificador == "") {
        showError("error", "Selecione uma conta.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }
    var $tr = $('#direcionamento_conta_' + identificador, '#frmDireciona');
    var cdcooper = $tr.find('input[name="cdcooper"]').val();
    var nrdconta = $tr.find('input[name="nrdconta"]').val().replace('/./g', '');
    showConfirmacao('Confirma o direcionamento da portabilidade?', 'Confirma&ccedil;&atilde;o - Aimaro', 'direcionarPortabilidade("'+dsrowid+'", "'+cdcooper+'", "'+nrdconta+'")', 'blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
}
function exibirDevolucaoPortabilidade(dsrowid) {
    showMsgAguardo("Aguarde, carregando ...");
    exibeRotina($('#divUsoGenerico'));

    var cddopcao = cabecalho.getOpcaoSelecionada();
    $('#divUsoGenerico').html('');
    $.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/solpor/form_devolve_solicitacao.php",
		data: {
            dsrowid: dsrowid,
            cddopcao: cddopcao,
			redirect: "script_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
            if (response.substr(0, 14) == 'hideMsgAguardo') {
                eval(response);
            } else {
                $('#divUsoGenerico').html(response);
                hideMsgAguardo();
                bloqueiaFundo($('#divUsoGenerico'));
                ajustarCentralizacao($('#divUsoGenerico'));
                formatarGridContas();
            }
		}
	});
}
function exibirDirecionanamentoPortabilidade(dsrowid) {
    showMsgAguardo("Aguarde, carregando ...");
    exibeRotina($('#divUsoGenerico'));

    var cddopcao = cabecalho.getOpcaoSelecionada();
    $('#divUsoGenerico').html('');
    $.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/solpor/form_direciona_solicitacao.php",
		data: {
            dsrowid: dsrowid,
            cddopcao: cddopcao,
			redirect: "script_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
            if (response.substr(0, 14) == 'hideMsgAguardo') {
                eval(response);
            } else {
                $('#divUsoGenerico').html(response);
                hideMsgAguardo();
                bloqueiaFundo($('#divUsoGenerico'));
                ajustarCentralizacao($('#divUsoGenerico'));
                formatarGridContas();
            }
		}
	});
}
function validarReprovacaoPortabilidade(dsrowid) {
    var cdmotivo = $("#motivoPortabilidade", "#frmReprovacao").val();
    if (cdmotivo == "") {
        showError("error", "Selecione uma situa&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        return false;
    }
    showConfirmacao('Confirma a reprova&ccedil;&atilde;o da portabilidade?', 'Confirma&ccedil;&atilde;o - Aimaro', 'avaliarPortabilidade("3", "'+dsrowid+'", "'+cdmotivo+'")', 'blockBackground(parseInt($("#divRotina").css("z-index")))', 'sim.gif', 'nao.gif');
}
function exibirReprovacaoPortabilidade(dsrowid) {
    showMsgAguardo("Aguarde, carregando ...");
    exibeRotina($('#divUsoGenerico'));

    var cddopcao = cabecalho.getOpcaoSelecionada();
    $('#divUsoGenerico').html('');
    $.ajax({
		dataType: "html",
		type: "POST",
		url: UrlSite + "telas/solpor/form_reprova_solicitacao.php",
		data: {
            dsrowid: dsrowid,
            cddopcao: cddopcao,
			redirect: "script_ajax"
		},
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
		},
        success: function (response) {
            if (response.substr(0, 14) == 'hideMsgAguardo') {
                eval(response);
            } else {
                $('#divUsoGenerico').html(response);
                hideMsgAguardo();
                bloqueiaFundo($('#divUsoGenerico'));
				ajustarCentralizacao($('#divUsoGenerico'));
			}
		}
	});
}
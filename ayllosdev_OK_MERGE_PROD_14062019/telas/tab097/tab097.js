//*********************************************************************************************//
//*** Fonte: tab097.js                                                 						***//
//*** Autor: Jaison Fernando                                           						***//
//*** Data : Novembro/2015                  Última Alteração: 17/04/2019  					***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de funções da tela TAB097                 						***//
//***                                                                  						***//	 
//*** Alterações: 03/08/2017 - Ajuste para utilizar a packge ZOOM0001(Adriano).             ***//
//***             17/04/2019 - Adicionado nova tabela referente a indexcecao 3.             ***//
//***                          RITM0012246 (Mateus Z - Mouts)                               ***//
//*********************************************************************************************//

var cCddopcao;
var cCdcooper;
var frmCab = 'frmCab';
var frmTab097 = 'frmTab097';
var cTodos;
var cddopcao = 'C';
var cTodosCabecalho;

$(document).ready(function() {

    estadoInicial();

    highlightObjFocus($('#frmCab'));

    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});

    return false;
});

function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);
    $('#frmCab').css({'display': 'block'});
    $('#divMsgAjuda').css('display', 'none');
    $('#divBotao').css('display', 'none');
    $('#divFormulario').html('');

    formataCabecalho();

    cTodosCabecalho.habilitaCampo();

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    $("#cddopcao", "#frmCab").val('C').focus();

    return false;
}

function formataCabecalho() {

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);

    var cddopcao = $("#cddopcao", "#frmCab").val();

    var rCddopcao = $('label[for="cddopcao"]', '#frmCab');

    rCddopcao.css('width', '50px').addClass('rotulo');

    cCddopcao = $('#cddopcao', '#frmCab');
    cCddopcao.css('width', '565px');

    cCddopcao.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 13 || e.keyCode == 9 || e.KeyCode == 18) {
            controlaOperacao(1,30);
            return false;
        }
    });

    cCddopcao.unbind('changed').bind('changed', function(e) {
        controlaOperacao(1,30);
        return false;
    });

}

function btnOK(nriniseq,nrregist) {
	if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    } else {
        controlaOperacao(1,30);
    }
}

function formataFormulario() {

    cTodosFormulario = $('input[type="text"],input[type="checkbox"],select', '#frmTab097');

    highlightObjFocus($('#frmTab097'));

    var cddopcao = $("#cddopcao", "#frmCab").val();

    var rQtminimo_negativacao = $('label[for="qtminimo_negativacao"]', '#frmTab097');
    var rQtmaximo_negativacao = $('label[for="qtmaximo_negativacao"]', '#frmTab097');
    var rHrenvio_arquivo      = $('label[for="hrenvio_arquivo"]',      '#frmTab097');
    var rVlminimo_boleto      = $('label[for="vlminimo_boleto"]',      '#frmTab097');
    var rQtdias_vencimento    = $('label[for="qtdias_vencimento"]',    '#frmTab097');
    var rQtdias_negativacao   = $('label[for="qtdias_negativacao"]',   '#frmTab097');
    var rAcao_cnae            = $('label[for="acao_cnae"]',            '#frmTab097');
    var rAcao_uf              = $('label[for="acao_uf"]',              '#frmTab097');
    var rAcao_uf_neg_dif      = $('label[for="acao_uf_neg_dif"]',      '#frmTab097');
    var rAcao_uf_neg_rec      = $('label[for="acao_uf_neg_rec"]',      '#frmTab097');
	
	rQtminimo_negativacao.addClass('rotulo').css('width','200px');
	rQtmaximo_negativacao.addClass('rotulo').css('width','200px');
    rHrenvio_arquivo.addClass('rotulo').css('width','200px');
    rVlminimo_boleto.addClass('rotulo').css('width', '200px');
    rQtdias_vencimento.addClass('rotulo').css('width', '200px');
    rQtdias_negativacao.addClass('rotulo').css('width', '200px');
    rAcao_cnae.addClass('rotulo').css('width', '200px');
    rAcao_uf.addClass('rotulo').css('width', '200px');
    rAcao_uf_neg_dif.addClass('rotulo').css('width', '200px');
    rAcao_uf_neg_rec.addClass('rotulo').css('width', '200px');

    var cQtminimo_negativacao = $('#qtminimo_negativacao', '#frmTab097');
    var cQtmaximo_negativacao = $('#qtmaximo_negativacao', '#frmTab097');
    var cHrenvio_arquivo      = $('#hrenvio_arquivo',      '#frmTab097');
    var cVlminimo_boleto      = $('#vlminimo_boleto',      '#frmTab097');
    var cQtdias_vencimento    = $('#qtdias_vencimento',    '#frmTab097');
    var cQtdias_negativacao   = $('#qtdias_negativacao',   '#frmTab097');
    var cAcao_cnae            = $('#acao_cnae',            '#frmTab097');
    var cAcao_uf              = $('#acao_uf',              '#frmTab097');
    var cAcao_uf_neg_dif      = $('#acao_uf_neg_dif',      '#frmTab097');
    var cAcao_uf_neg_rec      = $('#acao_uf_neg_rec',      '#frmTab097');

    cQtminimo_negativacao.css('width', '80px').setMask('INTEGER', 'zz', '', '');
    cQtmaximo_negativacao.css('width', '80px').setMask('INTEGER', 'zz', '', '');
    cHrenvio_arquivo.css('width', '80px').mask('00:00');
    cHrenvio_arquivo.setMask('STRING', '99:99', ':', '');
    cVlminimo_boleto.css('width', '80px').setMask('DECIMAL','zzz.zzz.zzz.zz9,99','.','');
    cQtdias_vencimento.css('width', '80px').setMask('INTEGER', 'zz', '', '');
    cQtdias_negativacao.css('width', '80px').setMask('INTEGER', 'zz', '', '');
    cAcao_cnae.css('width', '80px');
    cAcao_uf.css('width', '80px');
    cAcao_uf_neg_dif.css('width', '80px');
    cAcao_uf_neg_rec.css('width', '80px');
    
    // Oculta botoes excluir e tabela Acao
    $(".clsExcCNAE").hide();
    $(".clsExcUF").hide();
    $(".clsExcUFNegDif").hide();
    $(".clsAltUFNegDif").hide();
    $(".clsExcUFNegRec").hide();
    $(".clsAltUFNegRec").hide();
    $("#tabAcao").hide();
    $("#tabAcaoUF").hide();
    $("#tabAcaoUFNegDif").hide();
    $("#tabAcaoUFNegRec").hide();

    if (cddopcao == "C") {

        cTodosFormulario.desabilitaCampo();
        $('#divMsgAjuda').css('display', 'block');
        $('#divBotao').css('display', 'block');
        $('#btVoltar', '#divMsgAjuda').show();
        $('#btVoltar', '#divBotao').show();
        $("#btAlterar", "#divMsgAjuda").hide();
        $('#cddopcao', '#frmCab').focus();

    } else {

        cTodosFormulario.habilitaCampo();
        
        $("#tabAcao").show();
        $("#tabAcaoUF").show();
        $("#tabAcaoUFNegDif").show();
        $("#tabAcaoUFNegRec").show();
		
        $('#divMsgAjuda').css('display', 'block');
        $('#divBotao').css('display', 'block');
        $('#btVoltar', '#divMsgAjuda').show();
        $('#btVoltar', '#divBotao').show();
        $("#btAlterar", "#divMsgAjuda").show();        

		cTodosFormulario.bind('cut copy paste', function(e) {
			e.preventDefault();
		});
		
        cQtminimo_negativacao.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cQtmaximo_negativacao.focus();
                return false;
            }
        });

        cQtmaximo_negativacao.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cHrenvio_arquivo.focus();
                return false;
            }
        });

        cHrenvio_arquivo.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cVlminimo_boleto.focus();
                return false;
            }
        });

        cVlminimo_boleto.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cQtdias_vencimento.focus();
                return false;
            }
        });

        cQtdias_vencimento.keypress(function (e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cQtdias_negativacao.focus();
                return false;
            }
        });

        cQtdias_negativacao.keypress(function (e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                alterarDados();
                return false;
            }
        });
    }

    $('#frmTab097').css('display', 'block');
    return false;
}

// Botao Voltar
function btnVoltar() {
    estadoInicial();
    return false;
}

function controlaOperacao(nriniseq,nrregist) {
	
    var cddopcao = $("#cddopcao", "#frmCab").val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/tab097/obtem_consulta.php",
        data: {
            cddopcao: cddopcao,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        success: function(response) {
            if (response.substr(0, 14) == 'hideMsgAguardo') {
                eval(response);
            } else {
                $('#divFormulario').html(response);
                $('#divPesquisaRodape', '#frmTab097').formataRodapePesquisa();
                formataFormulario();
                formataGridCNAE();
                formataGridUF();
                formataGridUFNegDif();
                formataGridUFNegRec();
                cTodosCabecalho.desabilitaCampo();

                hideMsgAguardo();

                if (cddopcao == 'A') {
                    $('#qtminimo_negativacao', '#frmTab097').focus();
                }

                if ($('#cdcooper', '#frmTab097').val() != 3) {
                    $('#hrenvio_arquivo', '#frmTab097').desabilitaCampo();
                    $('#qtdias_vencimento', '#frmTab097').desabilitaCampo();
                    $('#qtdias_negativacao', '#frmTab097').desabilitaCampo();
                }

            }
		
		}

    });

    return false;

}

function alterarDados() {
    showConfirmacao('Confirma a atualiza&ccedil;&atilde;o dos parametros?', 'Tab097', 'grava_dados("PARAM","A","0");', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
}

function confirmaExclusao(acao, dsvalor) {
    var msg = 'o CNAE';
    if (acao != 'CNAE') {
        msg = 'a UF';
    }
    showConfirmacao("Deseja excluir " + msg + " da lista?", 'Confirma&ccedil;&atilde;o - Ayllos', 'grava_dados("' + acao + '","E","' + dsvalor + '")', '', 'sim.gif', 'nao.gif');
}

function abreTelAlteracao(dsvalor) {
    $('#hdnvalor', '#frmTab097').val(dsvalor);
    executarAcao('ALT_UFNegDif');
}

function confirmaInclusao(acao) {

    if (acao == 'CNAE') {
        var cdcnae = normalizaNumero($('#cdcnae', '#frmCNAE').val());
        if (cdcnae == 0) {
            showError("error", "Informe o c&oacute;digo.", "Alerta - Ayllos", "$('#cdcnae','#frmCNAE').focus();bloqueiaFundo($('#divRotina'));");
        } else {
            showConfirmacao("Deseja incluir o CNAE na lista?", 'Confirma&ccedil;&atilde;o - Ayllos', 'grava_dados("' + acao + '","I","' + cdcnae + '")', '', 'sim.gif', 'nao.gif');
        }
    } else { // UF
        var cddopcao = $('#cddopcao', '#frmUF').val();
        var indexcecao = $('#indexcecao', '#frmUF').val();
        var dsuf = $('#dsuf', '#frmUF').val();
        var qtminimo_negativacao = normalizaNumero($('#qtminimo_negativacao', '#frmUF').val());
        var qtmaximo_negativacao = normalizaNumero($('#qtminimo_negativacao', '#frmUF').val());

        if (dsuf == '') {
            showError("error", "Informe a UF.", "Alerta - Ayllos", "$('#dsuf','#frmUF').focus();bloqueiaFundo($('#divRotina'));");
        } else if ((indexcecao == 2 || indexcecao == 3) && qtminimo_negativacao == 0) {
            showError("error", "Informe o prazo.", "Alerta - Ayllos", "$('#qtminimo_negativacao','#frmUF').focus();bloqueiaFundo($('#divRotina'));");
        } else {
            var dsvalor = indexcecao + '|' + dsuf + '|' + qtminimo_negativacao + '|' + qtmaximo_negativacao;
            showConfirmacao("Deseja " + (cddopcao == 'I' ? 'incluir' : 'alterar') + " a UF na lista?", 'Confirma&ccedil;&atilde;o - Ayllos', 'grava_dados("' + acao + '","' + cddopcao + '","' + dsvalor + '")', '', 'sim.gif', 'nao.gif');
        }
    }

}

function grava_dados(acao, cddopcao, dsvalor) {

    // Campos de parametrizacao
    var qtminimo_negativacao = $('#qtminimo_negativacao', '#frmTab097').val();
    var qtmaximo_negativacao = $('#qtmaximo_negativacao', '#frmTab097').val();
    var hrenvio_arquivo = $('#hrenvio_arquivo', '#frmTab097').val();
    var vlminimo_boleto = $('#vlminimo_boleto', '#frmTab097').val();
    var qtdias_vencimento = $('#qtdias_vencimento', '#frmTab097').val();
    var qtdias_negativacao = $('#qtdias_negativacao', '#frmTab097').val();

    // Caso seja cadastro de UF
    if (acao == 'UF') {
        var arrDados = dsvalor.split('|');
        var indexcecao = arrDados[0];
        var dsuf = arrDados[1];
        var qtminimo_negativacao = arrDados[2] == 0 ? '' : arrDados[2];
        var qtmaximo_negativacao = arrDados[3] == 0 ? '' : arrDados[3];
        var dsvalor = indexcecao + '|' + dsuf;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/tab097/grava_dados.php",
        data: {
            acao                 : acao,
            cddopcao             : cddopcao,
            dsvalor              : dsvalor,
            qtminimo_negativacao : qtminimo_negativacao,
            qtmaximo_negativacao : qtmaximo_negativacao,
            hrenvio_arquivo      : hrenvio_arquivo,
            vlminimo_boleto      : vlminimo_boleto,
            qtdias_vencimento    : qtdias_vencimento,
            qtdias_negativacao   : qtdias_negativacao,
            redirect             : "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        success: function(response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
            }
        }

    });

}

function formataGridCNAE(){
	
    var divRegistro = $('#divCNAE');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'100px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';    

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;	
}

function formataGridUF() {

    var divRegistro = $('#divUF');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '70px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
    return false;
}

function formataGridUFNegDif() {

    var divRegistro = $('#divUFNegDif');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '70px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '100px';
    arrayLargura[2] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
    return false;
}

function formataGridUFNegRec() {

    var divRegistro = $('#divUFNegRec');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '70px' });

    var ordemInicial = new Array();
    ordemInicial = [[0, 0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '100px';
    arrayLargura[2] = '100px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'left';
    arrayAlinha[2] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);
    return false;
}

function executarAcao(acao_combo) {

    switch (acao_combo) {
        case 'UF':
            var cddopcao = $('#acao_uf', '#frmTab097').val();
            var dsvalor = '1|NA';
            var page = 'form_uf.php';
            break;
        case 'UFNegDif':
            var cddopcao = $('#acao_uf_neg_dif', '#frmTab097').val();
            var dsvalor = '2|NA';
            var page = 'form_uf.php';
            break;
        case 'ALT_UFNegDif':
            var cddopcao = 'A';
            var page = 'form_uf.php';
            var dsvalor = $('#hdnvalor', '#frmTab097').val();
            var acao_combo = 'UFNegDif';
            break; 
        case 'UFNegRec':
            var cddopcao = $('#acao_uf_neg_rec', '#frmTab097').val();
            var dsvalor = '3|NA';
            var page = 'form_uf.php';
            break;
        case 'ALT_UFNegRec':
            var cddopcao = 'A';
            var page = 'form_uf.php';
            var dsvalor = $('#hdnvalor', '#frmTab097').val();
            var acao_combo = 'UFNegRec';
            break;     
        default: // CNAE
            var cddopcao = $('#acao_cnae', '#frmTab097').val();
            var page = 'form_cnae.php';
    }

    // Oculta botoes excluir
    $(".clsExcCNAE").hide();
    $(".clsExcUF").hide();
    $(".clsExcUFNegDif").hide();
    $(".clsAltUFNegDif").hide();
    $(".clsExcUFNegRec").hide();
    $(".clsAltUFNegRec").hide();

    if (cddopcao == "E") { // Excluir

        $(".clsExc" + acao_combo).show(); // Exibe botoes excluir

    } else if (cddopcao == "ALT") { // Alterar

        $(".clsAlt" + acao_combo).show(); // Exibe botoes alterar

    } else { // Incluir ou Alterar

        showMsgAguardo('Aguarde, carregando...');

        // Executa script através de ajax
        $.ajax({		
            type: 'POST',
            dataType: 'html',
            url: UrlSite + 'telas/tab097/' + page, 
            data: {
                      acao    : acao_combo,
                      cddopcao: cddopcao,
                      dsvalor : dsvalor,
                      redirect: 'html_ajax'			
                  }, 
            error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
            },
            success: function(response) {
                $('#divRotina').html(response);
                exibeRotina($('#divRotina'));
                hideMsgAguardo();
                bloqueiaFundo($('#divRotina'));
            }				
        });
        return false;
    }
}

function mostraPesquisaCNAE() {

    var procedure, titulo, qtReg, filtros, colunas;

	procedure	= 'BUSCA_CNAE';
    titulo      = 'CNAE';
    qtReg		= '30';
    filtros 	= 'Cód. CNAE;cdcnae;60px;S;0;;descricao|Desc. CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;1;N;;descricao';
    colunas 	= 'Código;cdcnae;20%;right|Desc CNAE;dscnae;80%;left';

    mostraPesquisa('ZOOM0001',procedure,titulo,qtReg,filtros,colunas,$('#divRotina'));
	return false;

}

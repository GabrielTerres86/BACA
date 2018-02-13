//*********************************************************************************************//
//*** Fonte: parprt.js                                                 						***//
//*** Autor: Andre Clemer                                           						***//
//*** Data : Janeiro/2018                  �ltima Altera��o: --/--/----  					***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de fun��es da tela PARPRT                 						***//
//***                                                                  						***//	 
//*** Altera��es:                                                                          ***//
//*********************************************************************************************//

var cCddopcao;
var cCdcooper;
var frmCab = 'frmCab';
var frmParPrt = 'frmParPrt';
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
    var rCdcooper = $('label[for="cdcooper"]', '#frmCab');

    rCddopcao.css('width', '50px').addClass('rotulo');
    rCdcooper.css('width', '80px').addClass('rotulo-linha');

    cCddopcao = $('#cddopcao', '#frmCab');
    cCddopcao.css('width', '330px');

    cCdcooper = $('#cdcooper', '#frmCab');

    var ehCentral = cCdcooper.length > 0;

    if(ehCentral) {
        cCdcooper.html(slcooper);
        cCdcooper.css('width', '125px').attr('maxlength', '2');
    } else {
        cCddopcao.css('width', '565px');
    }

    cCddopcao.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 13 || e.keyCode == 9 || e.KeyCode == 18) {
            //controlaOperacao(1,30);
            cCdcooper.focus();
            return false;
        }
    });

    cCddopcao.unbind('changed').bind('changed', function(e) {
        //controlaOperacao(1,30);
        cCdcooper.focus();
        return false;
    });

    if(ehCentral) {

        cCdcooper.unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 13) {
                controlaOperacao(1,30);
                return false;
            }
        });

        cCdcooper.unbind('changed').bind('changed', function(e) {
            controlaOperacao(1,30);
            return false;
        });
    }

}

function btnOK(nriniseq,nrregist) {
	if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    } else {
        controlaOperacao(1,30);
    }
}

function formataFormulario() {

    cTodosFormulario = $('input[type="text"],input[type="checkbox"],select', '#frmParPrt');

    highlightObjFocus($('#frmParPrt'));

    var cddopcao = $("#cddopcao", "#frmCab").val();

    var rLimitemin_tolerancia = $('label[for="qtlimitemin_tolerancia"]',    '#frmParPrt');
    var rLimitemax_tolerancia = $('label[for="qtlimitemax_tolerancia"]',    '#frmParPrt');
    var rHrenvio_arquivo      = $('label[for="hrenvio_arquivo"]',           '#frmParPrt');
    var rQtdias_cancelamento  = $('label[for="qtdias_cancelamento"]',       '#frmParPrt');
    var rFlcancelamento       = $('label[for="flcancelamento"]',            '#frmParPrt');
    var rAcao_cnae            = $('label[for="acao_cnae"]',                 '#frmParPrt');
    var rAcao_uf              = $('label[for="acao_uf"]',                   '#frmParPrt');
	
	rLimitemin_tolerancia.addClass('rotulo').css('width','230px');
	rLimitemax_tolerancia.addClass('rotulo').css('width','230px');
    rHrenvio_arquivo.addClass('rotulo').css('width','230px');
    rQtdias_cancelamento.addClass('rotulo').css('width', '230px');
    rFlcancelamento.addClass('rotulo').css('width', '230px');
    rAcao_cnae.addClass('rotulo').css('width', '230px');
    rAcao_uf.addClass('rotulo').css('width', '230px');

    var cLimitemin_tolerancia = $('#qtlimitemin_tolerancia', '#frmParPrt');
    var cLimitemax_tolerancia = $('#qtlimitemax_tolerancia', '#frmParPrt');
    var cHrenvio_arquivo      = $('#hrenvio_arquivo',      '#frmParPrt');
    var cQtdias_cancelamento  = $('#qtdias_cancelamento',  '#frmParPrt');
    var cAcao_cnae            = $('#acao_cnae',            '#frmParPrt');
    var cAcao_uf              = $('#acao_uf',              '#frmParPrt');

    cLimitemin_tolerancia.css('width', '80px').setMask('INTEGER', 'zz', '', '');
    cLimitemax_tolerancia.css('width', '80px').setMask('INTEGER', 'zz', '', '');
    cHrenvio_arquivo.css('width', '80px').mask('00:00');
    cHrenvio_arquivo.setMask('STRING', '99:99', ':', '');
    cQtdias_cancelamento.css('width', '80px').setMask('INTEGER', 'zz', '', '');
    cAcao_cnae.css('width', '80px');
    cAcao_uf.css('width', '80px');
    
    // Oculta botoes excluir e tabela Acao
    $(".clsExcCNAE").hide();
    $(".clsExcUF").hide();
    $("#tabAcao").hide();
    $("#tabAcaoUF").hide();
    $("#tabAcaoUFNegDif").hide();

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
		
        $('#divMsgAjuda').css('display', 'block');
        $('#divBotao').css('display', 'block');
        $('#btVoltar', '#divMsgAjuda').show();
        $('#btVoltar', '#divBotao').show();
        $("#btAlterar", "#divMsgAjuda").show();        

		cTodosFormulario.bind('cut copy paste', function(e) {
			e.preventDefault();
		});
		
        cLimitemin_tolerancia.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cLimitemax_tolerancia.focus();
                return false;
            }
        });

        cLimitemax_tolerancia.keypress(function(e) {
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

        cQtdias_cancelamento.keypress(function (e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cQtdias_negativacao.focus();
                return false;
            }
        });
    }

    $('#frmParPrt').css('display', 'block');
    return false;
}

// Botao Voltar
function btnVoltar() {
    estadoInicial();
    return false;
}

function controlaOperacao(nriniseq,nrregist) {
	
    var cddopcao = $("#cddopcao", "#frmCab").val();
    var cdcooper = $('#cdcooper', '#frmCab').val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conte�do da op��o atrav�s de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/parprt/obtem_consulta.php",
        data: {
            cddopcao: cddopcao,
            cdcooper: cdcooper,
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
                $('#divPesquisaRodape', '#frmParPrt').formataRodapePesquisa();
                formataFormulario();
                formataGridCNAE();
                formataGridUF();
                cTodosCabecalho.desabilitaCampo();

                hideMsgAguardo();

                if (cddopcao == 'A') {
                    $('#limitemin_tolerancia', '#frmParPrt').focus();
                }

                if ($('#cdcooper', '#frmParPrt').val() != 3) {
                    // $('#hrenvio_arquivo', '#frmParPrt').desabilitaCampo();
                }

            }
		
		}

    });

    return false;

}

function alterarDados() {
    showConfirmacao('Confirma a atualiza&ccedil;&atilde;o dos parametros?', 'ParPrt', 'grava_dados("PARAM","A","0");', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
}

function confirmaExclusao(acao, dsvalor) {
    var msg = 'o CNAE';
    if (acao != 'CNAE') {
        msg = 'a UF';
    }
    showConfirmacao("Deseja excluir " + msg + " da lista?", 'Confirma&ccedil;&atilde;o - Ayllos', 'grava_dados("' + acao + '","E","' + dsvalor + '")', '', 'sim.gif', 'nao.gif');
}

function abreTelAlteracao(dsvalor) {
    $('#hdnvalor', '#frmParPrt').val(dsvalor);
    executarAcao('ALT_UFNegDif');
}

function confirmaInclusao(acao) {

    if (acao == 'CNAE') {
        var cdcnae = normalizaNumero($('#cdcnae', '#frmCNAE').val());
        var dsvalor = cdcnae + '|' + $('#dscnae', '#frmCNAE').val();
        if (cdcnae == 0) {
            showError("error", "Informe o c&oacute;digo.", "Alerta - Ayllos", "$('#cdcnae','#frmCNAE').focus();bloqueiaFundo($('#divRotina'));");
        } else {
            showConfirmacao("Deseja incluir o CNAE na lista?", 'Confirma&ccedil;&atilde;o - Ayllos', 'grava_dados("' + acao + '","I","' + dsvalor + '")', '', 'sim.gif', 'nao.gif');
        }
    } else { // UF
        var cddopcao = $('#cddopcao', '#frmUF').val();
        var dsuf = $('#dsuf', '#frmUF').val();

        if (dsuf == '') {
            showError("error", "Informe a UF.", "Alerta - Ayllos", "$('#dsuf','#frmUF').focus();bloqueiaFundo($('#divRotina'));");
        } else {
            showConfirmacao("Deseja " + (cddopcao == 'I' ? 'incluir' : 'alterar') + " a UF na lista?", 'Confirma&ccedil;&atilde;o - Ayllos', 'grava_dados("' + acao + '","' + cddopcao + '","' + dsuf + '")', '', 'sim.gif', 'nao.gif');
        }
    }

}

function grava_dados(acao, cddopcao, dsvalor) {

    // Campos de parametrizacao
    var cdcooper = $('#cdcooper', '#frmCab').val();
    var qtlimitemin_tolerancia = $('#qtlimitemin_tolerancia', '#frmParPrt').val();
    var qtlimitemax_tolerancia = $('#qtlimitemax_tolerancia', '#frmParPrt').val();
    var hrenvio_arquivo = $('#hrenvio_arquivo', '#frmParPrt').val();
    var qtdias_cancelamento = $('#qtdias_cancelamento', '#frmParPrt').val();
    var flcancelamento = $('#flcancelamento', '#frmParPrt').val();
    var cCnaes = $('#cnaes', '#frmParPrt');
    var dscnae = cCnaes.val();
    var cUFs = $('#ufs', '#frmParPrt');
    var dsuf = cUFs.val();

    // Caso seja cadastro de UF
    if (cddopcao == "E") { // Excluir
        if (acao == 'CNAE') {
            var arrCNAE = dscnae.split(',');
            for (var i=0, len = arrCNAE.length; i < len; ++i) {
                if (arrCNAE[i].split('|')[0] == dsvalor) {
                    arrCNAE.splice(i, 1);
                    break;
                }
            }
            dscnae = arrCNAE.join(',');
        }
        if (acao == 'UF') {
            var arrUF = dsuf.split(',');
            var index = arrUF.indexOf(dsvalor);
            if (index > -1) {
                arrUF.splice(index, 1);
                dsuf = arrUF.join(',');
            }
        }
    } else {
        if (acao == 'CNAE') {
            var arrDados = dsvalor.split('|');
            var idx = arrDados[0];
            var ds = arrDados[1];
            if (dscnae) {
                dscnae += ',' + idx + '|' + ds;
            } else {
                dscnae = idx + '|' + ds;
            }
        }

        if (acao == 'UF') {
            if (dsuf) {
                dsuf += ',' + dsvalor;
            } else {
                dsuf = dsvalor;
            }
        }
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

    // Carrega conte�do da op��o atrav�s de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/parprt/grava_dados.php",
        data: {
            acao                    : acao,
            cddopcao                : cddopcao,
            cdcooper                : cdcooper,
            dsuf                    : dsuf,
            dscnae                  : dscnae,
            qtlimitemin_tolerancia  : qtlimitemin_tolerancia,
            qtlimitemax_tolerancia  : qtlimitemax_tolerancia,
            hrenvio_arquivo         : hrenvio_arquivo,
            qtdias_cancelamento     : qtdias_cancelamento,
            flcancelamento          : flcancelamento,
            redirect                : "script_ajax" // Tipo de retorno do ajax
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

function executarAcao(acao_combo) {

    switch (acao_combo) {
        case 'UF':
            var cddopcao = $('#acao_uf', '#frmParPrt').val();
            var dsvalor = '1|NA';
            var page = 'form_uf.php';
            break;
        case 'UFNegDif':
            var cddopcao = $('#acao_uf_neg_dif', '#frmParPrt').val();
            var dsvalor = '2|NA';
            var page = 'form_uf.php';
            break;
        case 'ALT_UFNegDif':
            var cddopcao = 'A';
            var page = 'form_uf.php';
            var dsvalor = $('#hdnvalor', '#frmParPrt').val();
            var acao_combo = 'UFNegDif';
            break; 
        default: // CNAE
            var cddopcao = $('#acao_cnae', '#frmParPrt').val();
            var page = 'form_cnae.php';
    }

    // Oculta botoes excluir
    $(".clsExcCNAE").hide();
    $(".clsExcUF").hide();
    $(".clsExcUFNegDif").hide();
    $(".clsAltUFNegDif").hide();

    if (cddopcao == "E") { // Excluir

        $(".clsExc" + acao_combo).show(); // Exibe botoes excluir

    } else if (cddopcao == "ALT") { // Alterar

        $(".clsAlt" + acao_combo).show(); // Exibe botoes alterar

    } else { // Incluir ou Alterar

        showMsgAguardo('Aguarde, carregando...');

        // Executa script atrav�s de ajax
        $.ajax({		
            type: 'POST',
            dataType: 'html',
            url: UrlSite + 'telas/parprt/' + page, 
            data: {
                      acao    : acao_combo,
                      cddopcao: cddopcao,
                      dsvalor : dsvalor,
                      redirect: 'html_ajax'			
                  }, 
            error: function(objAjax,responseError,objExcept) {
                hideMsgAguardo();
                showError('error','N�o foi poss�vel concluir a requisi��o.','Alerta - Ayllos',"unblockBackground()");
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
    filtros 	= 'C�d. CNAE;cdcnae;60px;S;0;;descricao|Desc. CNAE;dscnae;200px;S;;;descricao|;flserasa;;N;1;N;;descricao';
    colunas 	= 'C�digo;cdcnae;20%;right|Desc CNAE;dscnae;80%;left';

    mostraPesquisa('ZOOM0001',procedure,titulo,qtReg,filtros,colunas,$('#divRotina'));
	return false;

}

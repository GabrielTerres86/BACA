//*********************************************************************************************//
//*** Fonte: parflu.js                                                 						***//
//*** Autor: Jaison Fernando                                           						***//
//*** Data : Outubro/2016                  Última Alteração: --/--/----  					***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de funções da tela                     						***//
//***                                                                  						***//	 
//*** Alterações: 																			***//
//*********************************************************************************************//

var cCddopcao;
var frmCab = 'frmCab';
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
    $('#divBotao').css('display', 'none');
    $('#divFormulario').html('');
    $('#divBotoes', '#divTela').html('').css({'display':'block'});

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

    cTodosFormulario = $('input[type="text"],input[type="checkbox"],select', '#frmParflu');
    cTodosFormulario.habilitaCampo();

    highlightObjFocus($('#frmParflu'));

    var cddopcao = $('#cddopcao', '#frmCab').val();

    if (cddopcao == "C") {

        var rConta_sysphera = $('label[for="conta_sysphera"]',   '#frmParflu');
        var cHdnconta       = $('#hdnconta',                     '#frmParflu');

        rConta_sysphera.addClass('rotulo').css('width', '110px');

        $("#divConta1", "#frmParflu").hide();
        $("#divConta2", "#frmParflu").hide();

        if (normalizaNumero(cHdnconta.val()) == 0) {
            var cConta_sysphera = $('#conta_sysphera', '#frmParflu');

            cConta_sysphera.css('width', '350px');

            $("#divConta1", "#frmParflu").show();
            cConta_sysphera.focus();

            cConta_sysphera.keypress(function (e) {
                if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                     $("#btProsseguir", "#frmParflu").focus();
                    return false;
                }
            });
        } else {
            $('#tabFieldC input').css({'width':'60px','text-align':'right'}).setMask('DECIMAL','zz9,99','.','');
            
            var cCdconta   = $('#cdconta', '#frmParflu');
            var cNmconta   = $('#nmconta', '#frmParflu');
            var cPerc_90   = $('#perc_90', '#frmParflu');
            var cPerc_180  = $('#perc_180', '#frmParflu');
            var cPerc_270  = $('#perc_270', '#frmParflu');
            var cPerc_360  = $('#perc_360', '#frmParflu');
            var cPerc_720  = $('#perc_720', '#frmParflu');
            var cPerc_1080 = $('#perc_1080', '#frmParflu');
            var cPerc_1440 = $('#perc_1440', '#frmParflu');
            var cPerc_1800 = $('#perc_1800', '#frmParflu');
            var cPerc_2160 = $('#perc_2160', '#frmParflu');
            var cPerc_2520 = $('#perc_2520', '#frmParflu');
            var cPerc_2880 = $('#perc_2880', '#frmParflu');
            var cPerc_3240 = $('#perc_3240', '#frmParflu');
            var cPerc_3600 = $('#perc_3600', '#frmParflu');
            var cPerc_3960 = $('#perc_3960', '#frmParflu');
            var cPerc_4320 = $('#perc_4320', '#frmParflu');
            var cPerc_4680 = $('#perc_4680', '#frmParflu');
            var cPerc_5040 = $('#perc_5040', '#frmParflu');
            var cPerc_5400 = $('#perc_5400', '#frmParflu');
            var cPerc_5401 = $('#perc_5401', '#frmParflu');

            cCdconta.css({'width':'50px','text-align':'center'}).desabilitaCampo();
            cNmconta.css({'width':'350px'}).attr('maxlength','200');

            $("#divConta2", "#frmParflu").show();
            $('#nmconta', '#frmParflu').focus();
            trocaBotao('Salvar','alterarDadosC()','btnVoltar()');

            cNmconta.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_90.focus();
                    return false;
                }
            });

            cPerc_90.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_180.focus();
                    return false;
                }
            });

            cPerc_180.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_270.focus();
                    return false;
                }
            });

            cPerc_270.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_360.focus();
                    return false;
                }
            });

            cPerc_360.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_720.focus();
                    return false;
                }
            });

            cPerc_720.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_1080.focus();
                    return false;
                }
            });

            cPerc_1080.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_1440.focus();
                    return false;
                }
            });

            cPerc_1440.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_1800.focus();
                    return false;
                }
            });

            cPerc_1800.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_2160.focus();
                    return false;
                }
            });

            cPerc_2160.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_2520.focus();
                    return false;
                }
            });

            cPerc_2520.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_2880.focus();
                    return false;
                }
            });

            cPerc_2880.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_3240.focus();
                    return false;
                }
            });

            cPerc_3240.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_3600.focus();
                    return false;
                }
            });

            cPerc_3600.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_3960.focus();
                    return false;
                }
            });

            cPerc_3960.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_4320.focus();
                    return false;
                }
            });

            cPerc_4320.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_4680.focus();
                    return false;
                }
            });

            cPerc_4680.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_5040.focus();
                    return false;
                }
            });

            cPerc_5040.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_5400.focus();
                    return false;
                }
            });

            cPerc_5400.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cPerc_5401.focus();
                    return false;
                }
            });

            cPerc_5401.keypress(function (e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    alterarDadosC();
                    return false;
                }
            });

        }

    } else if (cddopcao == 'R') {

        var rRemessa    = $('label[for="remessa"]', '#frmParflu');
        var cHdnremessa = $('#hdnremessa',          '#frmParflu');

        rRemessa.addClass('rotulo').css('width', '90px');

        $("#divRemessa1", "#frmParflu").hide();
        $("#divRemessa2", "#frmParflu").hide();

        if (normalizaNumero(cHdnremessa.val()) == 0) {
            var cRemessa = $('#remessa', '#frmParflu');

            cRemessa.css('width', '350px');

            $("#divRemessa1", "#frmParflu").show();
            cRemessa.focus();

            cRemessa.keypress(function (e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    $("#btProsseguir", "#frmParflu").focus();
                    return false;
                }
            });
        } else {
            var cCdremessa = $('#cdremessa', '#frmParflu');
            var cNmremessa = $('#nmremessa', '#frmParflu');
            var cTpfluxo_e = $('#tpfluxo_e', '#frmParflu');
            var cTpfluxo_s = $('#tpfluxo_s', '#frmParflu');
            var cFlremdina = $('#flremdina', '#frmParflu');
            var cCdbccxlt  = $('#cdbccxlt',  '#frmParflu');
            var cCdhistor  = $('#cdhistor',  '#frmParflu');
            var cDshistor  = $('#dshistor',  '#frmParflu');
            var cTphistor  = $('#tphistor',  '#frmParflu');
            var cTpfluxo   = $('#tpfluxo',   '#frmParflu');

            cCdremessa.css({'width':'50px','text-align':'center'}).desabilitaCampo();
            cNmremessa.css({'width':'320px'}).attr('maxlength','100');
            cCdhistor.css({'width':'50px','text-align':'center'}).setMask('INTEGER', 'zzzzz', '', '');
            cDshistor.css({'width':'150px'}).desabilitaCampo();
            cTphistor.css({'width':'60px'}).desabilitaCampo();

            $("#divRemessa2", "#frmParflu").show();
            $('#nmremessa', '#frmParflu').focus();
            trocaBotao('Salvar','alterarDadosR()','btnVoltarOpcaoR()');

            cCdhistor.bind('keydown', function (e) {
                var keyValue = getKeyValue(e);
                if (keyValue == 118) { // Se for F7
                    mostraPesquisaHistor();
                }
            });
	
            cCdhistor.unbind('blur').bind('blur', function(e) {		
                 carregaDadosHistor('carrega');
            });

            cNmremessa.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cTpfluxo_e.focus();
                    return false;
                }
            });

            cTpfluxo_e.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cTpfluxo_s.focus();
                    return false;
                }
            });

            cTpfluxo_s.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cFlremdina.focus();
                    return false;
                }
            });

            cFlremdina.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cCdbccxlt.focus();
                    return false;
                }
            });

            cCdbccxlt.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cTpfluxo.focus();
                    return false;
                }
            });

            cTpfluxo.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    cCdhistor.focus();
                    return false;
                }
            });

            cCdhistor.keypress(function(e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    $("#btAdicionar", "#frmParflu").focus();
                    return false;
                }
            });

        }
    }  else if (cddopcao == 'H') {

        var rCdcooper  = $('label[for="cdcooper"]', '#frmParflu');
        var cHdncooper = $('#hdncooper',            '#frmParflu');

        rCdcooper.addClass('rotulo').css('width', '90px');

        $("#divCooper1", "#frmParflu").hide();
        $("#divCooper2", "#frmParflu").hide();

        if (normalizaNumero(cHdncooper.val()) == 0) {
            var cCooper = $('#cooper', '#frmParflu');

            cCooper.css('width', '350px');

            $("#divCooper1", "#frmParflu").show();
            cCooper.focus();

            cCooper.keypress(function (e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    $("#btProsseguir", "#frmParflu").focus();
                    return false;
                }
            });
        } else {
            var cCdcooper = $('#cdcooper', '#frmParflu');
            var cNmcooper = $('#nmcooper', '#frmParflu');
            var cDshora   = $('#dshora',   '#frmParflu');

            cCdcooper.css({'width':'50px','text-align':'center'}).desabilitaCampo();
            cNmcooper.css({'width':'350px'}).desabilitaCampo();
            cDshora.mask('00:00');
            cDshora.css({'width':'50px'}).setMask('STRING','99:99',':','');

            $("#divCooper2", "#frmParflu").show();
            $('#dshora', '#frmParflu').focus();
            trocaBotao('Salvar','alterarDadosH()','btnVoltar()');

            cDshora.keypress(function (e) {
                if (e.keyCode == 13 || e.keyCode == 09) {
                    alterarDadosH();
                    return false;
                }
            });
        }
    } else if (cddopcao == 'M') {

        var cMargem_doc = $('#margem_doc', '#frmParflu');
        var cMargem_chq = $('#margem_chq', '#frmParflu');
        var cMargem_tit = $('#margem_tit', '#frmParflu');
        var cDevolu_chq = $('#devolu_chq', '#frmParflu');

        cMargem_doc.css({'width':'120px','text-align':'right'}).attr('alt', 'n2p2c2D').css('text-align', 'right').autoNumeric().trigger('blur');
        cMargem_chq.css({'width':'120px','text-align':'right'}).attr('alt', 'n2p2c2D').css('text-align', 'right').autoNumeric().trigger('blur');
        cMargem_tit.css({'width':'120px','text-align':'right'}).attr('alt', 'n2p2c2D').css('text-align', 'right').autoNumeric().trigger('blur');
        cDevolu_chq.css({'width':'120px','text-align':'right'}).attr('alt', 'n2p2c2D').css('text-align', 'right').autoNumeric().trigger('blur');

        $('#margem_doc', '#frmParflu').focus();
        trocaBotao('Salvar','alterarDadosM()','btnVoltar()');

        cMargem_doc.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09) {
                cMargem_chq.focus();
                return false;
            }
        });

        cMargem_chq.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09) {
                cMargem_tit.focus();
                return false;
            }
        });

        cMargem_tit.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09) {
                cDevolu_chq.focus();
                return false;
            }
        });

        cDevolu_chq.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09) {
                alterarDadosM();
                return false;
            }
        });
    }

    return false;
}

// Botao Voltar
function btnVoltar() {
    estadoInicial();
    return false;
}

function btnVoltarOpcaoR() {
    estadoInicial();
    $('#cddopcao', '#frmCab').val('R');
    controlaOperacao(1,30);
    return false;
}

function controlaOperacao(nriniseq,nrregist) {
	
    var cddopcao   = $("#cddopcao", "#frmCab").val();
    var hdnconta   = normalizaNumero($("#hdnconta", "#frmParflu").val());
    var hdncooper  = normalizaNumero($("#hdncooper", "#frmParflu").val());
    var hdnremessa = normalizaNumero($("#hdnremessa", "#frmParflu").val());

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/parflu/obtem_consulta.php",
        data: {
            cddopcao   : cddopcao,
            nriniseq   : nriniseq,
            nrregist   : nrregist,
            hdnconta   : hdnconta,
            hdncooper  : hdncooper,
            hdnremessa : hdnremessa,
            redirect   : "script_ajax" // Tipo de retorno do ajax
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
                formataFormulario();
                formataGridHistor();
                cTodosCabecalho.desabilitaCampo();
                hideMsgAguardo();
            }
		
		}

    });

    return false;

}

function mostraOpcaoC() {
    var conta_sysphera = normalizaNumero($('#conta_sysphera','#frmParflu').val());
    
    if (conta_sysphera == 0) {
        showError("error", "Informe a Conta Sysphera.", "Alerta - Ayllos", "$('#conta_sysphera','#frmParflu').focus();");
    } else {
        $('#hdnconta','#frmParflu').val(conta_sysphera);
        controlaOperacao(1,30);
    }
}

function mostraOpcaoR() {
    var remessa = normalizaNumero($('#remessa','#frmParflu').val());
    
    if (remessa == 0) {
        showError("error", "Informe a Remessa.", "Alerta - Ayllos", "$('#remessa','#frmParflu').focus();");
    } else {
        $('#hdnremessa','#frmParflu').val(remessa);
        controlaOperacao(1,30);
    }
}

function mostraOpcaoH() {
    var cooper = normalizaNumero($('#cooper','#frmParflu').val());
    
    if (cooper == 0) {
        showError("error", "Informe a Cooperativa.", "Alerta - Ayllos", "$('#cooper','#frmParflu').focus();");
    } else {
        $('#hdncooper','#frmParflu').val(cooper);
        controlaOperacao(1,30);
    }
}

function trocaBotao(sNomeBotaoSalvar,sFuncaoSalvar,sFuncaoVoltar) {
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+sFuncaoVoltar+'; return false;">Voltar</a>&nbsp;');

	if (sFuncaoSalvar != ''){
		$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="'+sFuncaoSalvar+'; return false;">'+sNomeBotaoSalvar+'</a>');	
	}
	return false;
}

function alterarDadosC() {
    showConfirmacao('Confirma atualiza&ccedil;&atilde;o dos per&iacute;odos?', 'PARFLU', 'grava_dados();', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
}

function alterarDadosR() {
    showConfirmacao('Confirma inclus&atilde;o dos hist&oacute;ricos?', 'PARFLU', 'grava_dados();', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
}

function alterarDadosH() {
    showConfirmacao('Confirma atualiza&ccedil;&atilde;o do hor&aacute;rio?', 'PARFLU', 'grava_dados();', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
}

function alterarDadosM() {
    showConfirmacao('Confirma atualiza&ccedil;&atilde;o dos percentuais?', 'PARFLU', 'grava_dados();', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
}

function grava_dados() {

    var cddopcao = $('#cddopcao', '#frmCab').val();

    if (cddopcao == 'C') {

        var cdconta   = normalizaNumero($('#cdconta', '#frmParflu').val());
        var nmconta   = $('#nmconta', '#frmParflu').val();
        var perc_90   = converteMoedaFloat($('#perc_90', '#frmParflu').val());
        var perc_180  = converteMoedaFloat($('#perc_180', '#frmParflu').val());
        var perc_270  = converteMoedaFloat($('#perc_270', '#frmParflu').val());
        var perc_360  = converteMoedaFloat($('#perc_360', '#frmParflu').val());
        var perc_720  = converteMoedaFloat($('#perc_720', '#frmParflu').val());
        var perc_1080 = converteMoedaFloat($('#perc_1080', '#frmParflu').val());
        var perc_1440 = converteMoedaFloat($('#perc_1440', '#frmParflu').val());
        var perc_1800 = converteMoedaFloat($('#perc_1800', '#frmParflu').val());
        var perc_2160 = converteMoedaFloat($('#perc_2160', '#frmParflu').val());
        var perc_2520 = converteMoedaFloat($('#perc_2520', '#frmParflu').val());
        var perc_2880 = converteMoedaFloat($('#perc_2880', '#frmParflu').val());
        var perc_3240 = converteMoedaFloat($('#perc_3240', '#frmParflu').val());
        var perc_3600 = converteMoedaFloat($('#perc_3600', '#frmParflu').val());
        var perc_3960 = converteMoedaFloat($('#perc_3960', '#frmParflu').val());
        var perc_4320 = converteMoedaFloat($('#perc_4320', '#frmParflu').val());
        var perc_4680 = converteMoedaFloat($('#perc_4680', '#frmParflu').val());
        var perc_5040 = converteMoedaFloat($('#perc_5040', '#frmParflu').val());
        var perc_5400 = converteMoedaFloat($('#perc_5400', '#frmParflu').val());
        var perc_5401 = converteMoedaFloat($('#perc_5401', '#frmParflu').val());
        var vltotperc = perc_90   + perc_180  + perc_270  + perc_360  + perc_720
                      + perc_1080 + perc_1440 + perc_1800 + perc_2160 + perc_2520
                      + perc_2880 + perc_3240 + perc_3600 + perc_3960 + perc_4320
                      + perc_4680 + perc_5040 + perc_5400 + perc_5401;

        if (nmconta == '') {
            showError("error", "Informe o nome.", "Alerta - Ayllos", "$('#nmconta','#frmParflu').focus();");
            return false;
        }

        if (vltotperc > 100) {
            showError("error", "Percentual distribuído nos períodos não pode ultrapassar 100%!");
            return false;
        }

        var nmIdField = '';
        $('#tabFieldC input').each(function(){
            if (converteMoedaFloat($(this).val()) > 100) {
                nmIdField = $(this).attr('id');
                return false;
            }
        });

        if (nmIdField != '') {
            showError("error", "Percentual m&aacute;ximo permitido: 100,00.", "Alerta - Ayllos", "$('#" + nmIdField + "','#frmParflu').focus();");
            return false;
        }

    } else if (cddopcao == 'R') {

        var cdremessa = normalizaNumero($('#cdremessa', '#frmParflu').val());
        var nmremessa = $('#nmremessa', '#frmParflu').val();
        var tpfluxo_e = $('#tpfluxo_e', '#frmParflu').val();
        var tpfluxo_s = $('#tpfluxo_s', '#frmParflu').val();
        var flremdina = $('#flremdina', '#frmParflu').val();
        var strReHiFl  = '';

        if (nmremessa == '') {
            showError("error", "Informe o nome.", "Alerta - Ayllos", "$('#nmremessa','#frmParflu').focus();");
            return false;
        }

        $('#tbodyHistor tr').each(function(){
            if ($(this).is(':visible') == true) {
                strReHiFl += (strReHiFl == '' ? '' : '#') + $(this).attr('id');
            }
        });

    } else if (cddopcao == 'H') {

        var cdcooper = normalizaNumero($('#cdcooper', '#frmParflu').val());
        var dshora   = $('#dshora', '#frmParflu').val();
        var inallcop = ($("#inallcop", "#frmParflu").prop("checked") ? 1 : 0);

        if (dshora == '') {
            showError("error", "Informe o horario.", "Alerta - Ayllos", "$('#dshora','#frmParflu').focus();");
            return false;
        }

    } else if (cddopcao == 'M') {

        var margem_doc = $('#margem_doc', '#frmParflu').val();
        var margem_chq = $('#margem_chq', '#frmParflu').val();
        var margem_tit = $('#margem_tit', '#frmParflu').val();
        var devolu_chq = $('#devolu_chq', '#frmParflu').val();

        if (margem_doc == '') {
            showError("error", "Informe o valor.", "Alerta - Ayllos", "$('#margem_doc','#frmParflu').focus();");
            return false;
        }

        if (margem_chq == '') {
            showError("error", "Informe o valor.", "Alerta - Ayllos", "$('#margem_chq','#frmParflu').focus();");
            return false;
        }

        if (margem_tit == '') {
            showError("error", "Informe o valor.", "Alerta - Ayllos", "$('#margem_tit','#frmParflu').focus();");
            return false;
        }

        if (devolu_chq == '') {
            showError("error", "Informe o valor.", "Alerta - Ayllos", "$('#devolu_chq','#frmParflu').focus();");
            return false;
        }

    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/parflu/grava_dados.php",
        data: {
            cddopcao  : cddopcao,
            // OPCAO C
            cdconta   : cdconta,
            nmconta   : nmconta,
            perc_90   : perc_90,
            perc_180  : perc_180,
            perc_270  : perc_270,
            perc_360  : perc_360,
            perc_720  : perc_720,
            perc_1080 : perc_1080,
            perc_1440 : perc_1440,
            perc_1800 : perc_1800,
            perc_2160 : perc_2160,
            perc_2520 : perc_2520,
            perc_2880 : perc_2880,
            perc_3240 : perc_3240,
            perc_3600 : perc_3600,
            perc_3960 : perc_3960,
            perc_4320 : perc_4320,
            perc_4680 : perc_4680,
            perc_5040 : perc_5040,
            perc_5400 : perc_5400,
            perc_5401 : perc_5401,
            // OPCAO R
            cdremessa : cdremessa,
            nmremessa : nmremessa,
            tpfluxo_e : tpfluxo_e,
            tpfluxo_s : tpfluxo_s,
            flremdina : flremdina,
            strReHiFl : strReHiFl,
            // OPCAO H
            cdcooper  : cdcooper,
            inallcop  : inallcop,
            dshora    : dshora,
            // OPCAO M
            margem_doc : margem_doc,
            margem_chq : margem_chq,
            margem_tit : margem_tit,
            devolu_chq : devolu_chq,

            redirect  : "script_ajax" // Tipo de retorno do ajax
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

function formataGridHistor() {
    
    var divRegistro = $('#divHistor');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'width':'658px','height':'200px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;	
}

function mostraPesquisaHistor() {
    var bo, procedure, titulo, qtReg, filtros, colunas;
    
    bo			= 'TELA_PARFLU'; 
	procedure	= 'PARFLU_BUSCA_HISTOR';
	titulo      = 'Historicos';
	qtReg		= '30';
    filtros 	= 'Codigo;cdhistor;80px;S;;S|Descricao;dshistor;280px;S;;S|;tphistor;;N;;N';
	colunas 	= 'Codigo;cdhistor;20%;right|Historico;dshistor;40%;left|Tipo;tphistor;40%;left';

    mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas);
	return false;
}

function carregaDadosHistor(dsaction) {

	var cdhistor = normalizaNumero($('#cdhistor','#frmParflu').val());
    if (cdhistor > 0) {
        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/parflu/busca_dados_histor.php",
            data: {
                cdhistor : cdhistor,
                dsaction : dsaction,
                redirect : "script_ajax" // Tipo de retorno do ajax
            },
            error: function(objAjax, responseError, objExcept) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cdhistor','#frmParflu').focus()");
            },
            success: function(response) {
                hideMsgAguardo();
                eval(response);
            }

        });
    }
}

function validaInclusao() {

    var cdhistor = normalizaNumero($('#cdhistor',  '#frmParflu').val());
    if (cdhistor == 0) {
        showError("error", "Informe o código.", "Alerta - Ayllos", "$('#cdhistor','#frmParflu').focus();");
    } else {
        var cdremessa = normalizaNumero($('#cdremessa', '#frmParflu').val());
        var tpfluxo   = $('#tpfluxo', '#frmParflu').val();
        var cdRehifl  = cdremessa + '_' + cdhistor + '_' + tpfluxo;
        var blnAchou  = false;

        $('#tbodyHistor tr').each(function(){
            if ($(this).attr('id') == cdRehifl &&
                $(this).is(':visible') == true) {
                blnAchou = true;
                return false;
            }
        });

        if (blnAchou) {
            showError("error", "Este registro já está adicionado na lista.", "Alerta - Ayllos", "resetaInclusao()");
        } else {
            carregaDadosHistor('confirma');
        }
    }

}

function confirmaInclusao() {
    showConfirmacao("Deseja incluir este registro na lista?", 'Confirma&ccedil;&atilde;o - Ayllos', 'adicionaLinha()', '', 'sim.gif', 'nao.gif');
}

function resetaInclusao() {
    $('#dshistor','#frmParflu').val('');
    $('#tphistor','#frmParflu').val('');
    $('#cdhistor','#frmParflu').val('').focus();
}

function adicionaLinha() {

    var cdremessa = normalizaNumero($('#cdremessa', '#frmParflu').val());
    var cdhistor  = normalizaNumero($('#cdhistor', '#frmParflu').val());
    var dshistor  = $('#dshistor', '#frmParflu').val();
    var tphistor  = $('#tphistor', '#frmParflu').val();
    var tpfluxo   = $('#tpfluxo', '#frmParflu').val();
    var dsfluxo   = $("#tpfluxo option:selected").text();
    var cdbanco   = $('#cdbccxlt', '#frmParflu').val();
    var dsbanco   = $("#cdbccxlt option:selected").text();
    var cdRehifl  = cdremessa + '_' + cdhistor + '_' + tpfluxo + '_' + cdbanco;
    var linHistor = '';
    var blnAchou  = false;

    $('#tbodyHistor tr').each(function(){
        if ($(this).attr('id') == cdRehifl) {
            blnAchou = true;
            return false;
        }
    });

    if (blnAchou) {
        $('#' + cdRehifl).show();
    } else {
        linHistor += '<tr id="' + cdRehifl + '">';
        linHistor += '    <td width="120">' + dsbanco + '</td>';
        linHistor += '    <td width="80">' + dsfluxo  + '</td>';
        linHistor += '    <td width="50">' + cdhistor + '</td>';
        linHistor += '    <td>' + dshistor + '</td>';
        linHistor += '    <td width="50">' + tphistor + '</td>';
        linHistor += '    <td width="60"><img onclick="confirmaExclusao(\'' + cdRehifl + '\');" style="cursor:hand;" src="../../imagens/geral/panel-error_16x16.gif" width="13" height="13" /></td>';
        linHistor += '</tr>';
    }

    // Remove o titulo dos registros
    $('#fsetFormulario .tituloRegistros').remove();
    // Inclui nova linha
    $('#tbodyHistor').append(linHistor);

    formataGridHistor();
    resetaInclusao();
    zebrarLinhas();

}

function confirmaExclusao(cdRehifl) {
    showConfirmacao("Deseja excluir este registro da lista?", 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirLinha("' + cdRehifl + '")', '', 'sim.gif', 'nao.gif');
}

function excluirLinha(cdRehifl) {
    $('#' + cdRehifl).hide();
    zebrarLinhas();
}

function zebrarLinhas() {
    $('#tbodyHistor tr').removeClass('corImpar').removeClass('corPar');

    var nmclasse = 'corImpar'
    $('#tbodyHistor tr').each(function(){
        if ($(this).is(':visible') == true) {
            $(this).addClass(nmclasse);
            nmclasse = (nmclasse == 'corImpar' ? 'corPar' : 'corImpar');
        }
    });
}

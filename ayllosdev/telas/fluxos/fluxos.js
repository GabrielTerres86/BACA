//*********************************************************************************************//
//*** Fonte: fluxos.js                                                 						***//
//*** Autor: Jaison Fernando                                           						***//
//*** Data : Outubro/2016                  Última Alteração: --/--/----  					***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de funções da tela FLUXOS                 						***//
//***                                                                  						***//	 
//*** Alterações: 																			***//
//*********************************************************************************************//

var cCddopcao, cDtmvtolt, cDtlimite, cTpdmovto, cCdcooper, cTodosCabecalho;
var rCddopcao, rDtmvtolt, rDtlimite, rTpdmovto, rCdcooper;

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
    $('#divFormulario').html('');
    $('#divBotoes', '#divTela').html('').css({'display':'block'});

    formataCabecalho();

    cTodosCabecalho.habilitaCampo();

    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    $('#cddopcao', '#frmCab').val('').focus();
    $('#btnOK',    '#frmCab').show();

    return false;
}

function formataCabecalho() {

    cTodosCabecalho = $('input[type="text"],select', '#frmCab');

    rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    rDtmvtolt = $('label[for="dtmvtolt"]', '#frmCab');
    rDtlimite = $('label[for="dtlimite"]', '#frmCab');
    rTpdmovto = $('label[for="tpdmovto"]', '#frmCab');
    rCdcooper = $('label[for="cdcooper"]', '#frmCab');

    rCddopcao.css('width', '50px').addClass('rotulo');
    rDtmvtolt.css('width', '77px').addClass('rotulo-linha').hide();
    rDtlimite.css('width', '25px').addClass('rotulo-linha').hide();
    rTpdmovto.css('width', '80px').addClass('rotulo-linha').hide();
    rCdcooper.css('width', '83px').addClass('rotulo-linha').hide();

    cCddopcao = $('#cddopcao', '#frmCab');
    cDtmvtolt = $('#dtmvtolt', '#frmCab');
    cDtlimite = $('#dtlimite', '#frmCab');
    cTpdmovto = $('#tpdmovto', '#frmCab');
    cCdcooper = $('#cdcooper', '#frmCab');

    cCddopcao.css('width', '565px');
    cDtmvtolt.css('width', '73px').hide().setMask("DATE","","","");
    cDtlimite.css('width', '73px').hide().setMask("DATE","","","");
    cTpdmovto.css('width', '150px').hide();
    cCdcooper.css('width', '100px').hide();

    cCddopcao.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 13 || e.keyCode == 9) {
            ativaCampoCabecalho();
            return false;
        }
    });

    cCddopcao.unbind('changed').bind('changed', function(e) {
        ativaCampoCabecalho();
        return false;
    });

}

function btnOK(nriniseq,nrregist) {
	if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    } else {
        ativaCampoCabecalho();
    }
}

function btnVoltar() {
    estadoInicial();
    return false;
}

function btnVoltarOpcaoF() {
    estadoInicial();
    $('#cddopcao', '#frmCab').val('F');
    ativaCampoCabecalho();
    return false;
}

function ativaCampoCabecalho() {

	cCddopcao.desabilitaCampo();
    cDtmvtolt.val(glb_dtmvtolt);
    $('#btnOK','#frmCab').hide();

    trocaBotao('Prosseguir','controlaOperacao()','btnVoltar()');

    if (glb_cdcooper != 3) {
        cCdcooper.desabilitaCampo();
    } else {
        $('#cdcooper option:first').html('Todas');
    }

    switch (cCddopcao.val()) {

        case 'F':
            rDtmvtolt.show();
            rTpdmovto.show();
            rCdcooper.show();
            cDtmvtolt.show();
            cTpdmovto.show();
            cCdcooper.show();

            cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    cTpdmovto.focus();
                    return false;
                }
            });

            cTpdmovto.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    if (glb_cdcooper == 3) {
                        cCdcooper.focus();
                    } else {
                        controlaOperacao();
                    }
                    return false;
                }
            });

            cCdcooper.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    controlaOperacao();
                    return false;
                }
            });
            break;

        case 'M':
            cCddopcao.css('width', '440px');
            rDtmvtolt.show();
            cDtmvtolt.show();

            cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    controlaOperacao();
                    return false;
                }
            });
            break;

        case 'G':
            cDtlimite.val(glb_dtmvtolt)
            trocaBotao('Prosseguir','abreDownload()','btnVoltar()');
            cCddopcao.css('width', '145px');
            rDtmvtolt.show();
            rDtlimite.show();
            rCdcooper.show();
            cDtmvtolt.show();
            cDtlimite.show();
            cCdcooper.show();

            cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    cDtlimite.focus();
                    return false;
                }
            });

            cDtlimite.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    if (glb_cdcooper == 3) {
                        cCdcooper.focus();
                    } else {
                        abreDownload();
                    }
                    return false;
                }
            });

            cCdcooper.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    abreDownload();
                    return false;
                }
            });
            break;

        case 'L':
        case 'R':
            cCddopcao.css('width', '250px');
            rDtmvtolt.show();
            rCdcooper.show();
            cDtmvtolt.show();
            cCdcooper.show();
            
            if (cCddopcao.val() == 'R' && glb_cdcooper == 3) {
                $('#cdcooper option:first').html('Selecione');
            }

            cDtmvtolt.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    if (glb_cdcooper == 3) {
                        cCdcooper.focus();
                    } else {
                        controlaOperacao();
                    }
                    return false;
                }
            });

            cCdcooper.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    controlaOperacao();
                    return false;
                }
            });
            break;

        default:
            showError("error", "Selecione uma opção.", "Alerta - Ayllos", "btnVoltar()");
    }

    cDtmvtolt.focus();
	return false;

}

function abreDownload() {

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/fluxos/obtem_consulta.php",
        data: {
            cddopcao: cCddopcao.val(),
            dtmvtolt: cDtmvtolt.val(),
            dtlimite: cDtlimite.val(),
            tpdmovto: cTpdmovto.val(),
            cdcooper: cCdcooper.val(),
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
                hideMsgAguardo();

                var dtIni = new Date(cDtmvtolt.val());
                var dtFim = new Date(cDtlimite.val());

                if (cDtmvtolt.val() == '') {
                    showError("error", "Informe a data.", "Alerta - Ayllos", "cDtmvtolt.focus()");
                    return false;
                } else if (cDtlimite.val() == '') {
                    showError("error", "Informe a data.", "Alerta - Ayllos", "cDtlimite.focus()");
                    return false;
                } else if (dtIni > dtFim) {
                    showError("error", "Informe uma data superior a data de referência.", "Alerta - Ayllos", "cDtlimite.val('').focus()");
                    return false;
                } else if (diffDays(cDtmvtolt.val(),cDtlimite.val()) > 365) {
                    showError("error", "Informe uma data com o prazo máximo de 12 meses.", "Alerta - Ayllos", "cDtlimite.val('').focus()");
                    return false;
                }

                window.open('csv.php?glb_cdcooper=' + glb_cdcooper + '&glb_cdagenci=' + glb_cdagenci + '&glb_nrdcaixa=' + glb_nrdcaixa + '&glb_idorigem=' + glb_idorigem + '&glb_cdoperad=' + glb_cdoperad + '&cdcooper=' + cCdcooper.val() + '&dtrefini=' + cDtmvtolt.val() + '&dtreffim=' + cDtlimite.val());
            }
		
		}

    });

}

function trocaBotao( botao,funcao,funcaoVoltar ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+funcaoVoltar+'; return false;">Voltar<a/>');
	
	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" id="btSalvar" onClick="'+funcao+'; return false;">'+botao+'</a>');
	}
	
	return false;
	
}

function diffDays(dt1, dt2) {
    var dat1  = dt1.split('/');
    var dat2  = dt2.split('/');
    var date1 = new Date(dat1[2], dat1[1], dat1[0]);
    var date2 = new Date(dat2[2], dat2[1], dat2[0]);
    var timeDiff = Math.abs(date2.getTime() - date1.getTime());
    var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
    return diffDays;
}

function controlaOperacao() {

    if (cDtmvtolt.val() == '') {
        showError("error", "Informe a data.", "Alerta - Ayllos", "cDtmvtolt.focus()");
        return false;
    }

    if (cCddopcao.val() == 'R' && cCdcooper.val() == 0) {
        showError("error", "Selecione uma cooperativa.", "Alerta - Ayllos", "cCdcooper.focus()");
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/fluxos/obtem_consulta.php",
        data: {
            cddopcao: cCddopcao.val(),
            dtmvtolt: cDtmvtolt.val(),
            dtlimite: cDtlimite.val(),
            tpdmovto: cTpdmovto.val(),
            cdcooper: cCdcooper.val(),
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
                cTodosCabecalho.desabilitaCampo();
                hideMsgAguardo();
            }
		
		}

    });

    return false;

}

function formataOpcaoR() {

    var cVldiv085 = $('#vldiv085', '#frmOpcaoR');
    var cVldiv001 = $('#vldiv001', '#frmOpcaoR');
    var cVldiv756 = $('#vldiv756', '#frmOpcaoR');
    var cVldiv748 = $('#vldiv748', '#frmOpcaoR');
    var cVlresgat = $('#vlresgat', '#frmOpcaoR');
    var cVlaplica = $('#vlaplica', '#frmOpcaoR');
    
    cVldiv085.attr('alt', 'n9p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    cVldiv001.attr('alt', 'n9p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    cVldiv756.attr('alt', 'n9p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    cVldiv748.attr('alt', 'n9p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    cVlresgat.attr('alt', 'n9p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');
    cVlaplica.attr('alt', 'n9p3c2D').css('text-align', 'right').autoNumeric().trigger('blur');

    cVldiv085.unbind('blur').bind('blur', function(e) {
        carregaValorDiversos();
    });

    cVldiv001.unbind('blur').bind('blur', function(e) {
        carregaValorDiversos();
    });

    cVldiv756.unbind('blur').bind('blur', function(e) {
        carregaValorDiversos();
    });

    cVldiv748.unbind('blur').bind('blur', function(e) {
        carregaValorDiversos();
    });

    cVlresgat.unbind('blur').bind('blur', function(e) {
        // Se foi informado resgate zera a aplicacao
        if (converteMoedaFloat($(this).val()) > 0) {
            $('#vlaplica', '#frmOpcaoR').val('0,00');
        }
        carregaValorDiversos();
    });

    cVlaplica.unbind('blur').bind('blur', function(e) {
        // Se foi informado aplicacao zera o resgate
        if (converteMoedaFloat($(this).val()) > 0) {
            $('#vlresgat', '#frmOpcaoR').val('0,00');
        }
        carregaValorDiversos();
    });

    cVldiv085.keypress(function(e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            cVldiv001.focus();
            return false;
        }
    });

    cVldiv001.keypress(function(e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            cVldiv756.focus();
            return false;
        }
    });

    cVldiv756.keypress(function(e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            cVldiv748.focus();
            return false;
        }
    });

    cVldiv748.keypress(function(e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            cVlresgat.focus();
            return false;
        }
    });

    cVlresgat.keypress(function(e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            cVlaplica.focus();
            return false;
        }
    });

    cVlaplica.keypress(function(e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            alterarDados();
            return false;
        }
    });

}

function carregaValorDiversos() {
    var vlentrad;
    var vlsaidas;
    var vldivers;
    var vldivtot = 0;
    var dsbancos = '085,001,756,748';
    var arrbanco = dsbancos.split(',');
    
    for (var i = 0; i < arrbanco.length; i++) {
        vlentrad = converteMoedaFloat($('#vlent' + arrbanco[i], '#frmOpcaoR').val());
        vlsaidas = converteMoedaFloat($('#vlsai' + arrbanco[i], '#frmOpcaoR').val());
        vldivers = converteMoedaFloat($('#vldiv' + arrbanco[i], '#frmOpcaoR').val());
        vldivtot += vldivers;
        // Popula o resultado centralizacao
        $('#vlres' + arrbanco[i], '#frmOpcaoR').val(number_format((vlentrad - vlsaidas + vldivers), 2, ',', '.'));
    }

    // Popula o total de diversos
    $('#vldivtot', '#frmOpcaoR').val(number_format(vldivtot, 2, ',', '.'));
    
    var vlsldcta = converteMoedaFloat($('#vlsldcta', '#frmOpcaoR').val());
    var vlresgat = converteMoedaFloat($('#vlresgat', '#frmOpcaoR').val());
    var vlaplica = converteMoedaFloat($('#vlaplica', '#frmOpcaoR').val());
    var vlenttot = converteMoedaFloat($('#vlenttot', '#frmOpcaoR').val());
    var vlsaitot = converteMoedaFloat($('#vlsaitot', '#frmOpcaoR').val());
    var vlrestot = vlenttot - vlsaitot + vldivtot;
    
    // Popula o resultado centralizacao e saldo final do total
    $('#vlrestot', '#frmOpcaoR').val(number_format(vlrestot, 2, ',', '.'));
    $('#vlsldfim', '#frmOpcaoR').val(number_format((vlrestot + vlsldcta + vlresgat - vlaplica), 2, ',', '.'));
}

function alterarDados() {
    showConfirmacao('Confirma altera&ccedil;&atilde;o dos valores?', 'PARFLU', 'grava_dados();', '', 'sim.gif', 'nao.gif');
}

function grava_dados() {

    var vldiv085 = $('#vldiv085', '#frmOpcaoR').val();
    var vldiv001 = $('#vldiv001', '#frmOpcaoR').val();
    var vldiv756 = $('#vldiv756', '#frmOpcaoR').val();
    var vldiv748 = $('#vldiv748', '#frmOpcaoR').val();
    var vldivtot = $('#vldivtot', '#frmOpcaoR').val();
    var vlresgat = $('#vlresgat', '#frmOpcaoR').val();
    var vlaplica = $('#vlaplica', '#frmOpcaoR').val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/fluxos/grava_dados.php",
        data: {
            cddopcao : cCddopcao.val(),
            cdcooper : cCdcooper.val(),
            dtrefere : cDtmvtolt.val(),
            vldiv085 : vldiv085,
            vldiv001 : vldiv001,
            vldiv756 : vldiv756,
            vldiv748 : vldiv748,
            vldivtot : vldivtot,
            vlresgat : vlresgat,
            vlaplica : vlaplica,
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

//*********************************************************************************************//
//*** Fonte: tab096.js                                                 						***//
//*** Autor: Lucas Reinert                                           						***//
//*** Data : Julho/2015                  Última Alteração: 07/03/2017  						***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de funções da tela TAB096                 						***//
//***                                                                  						***//	 
//*** Alterações: 07/03/2017 - Adicao do campo descprej. (P210.2 - Jaison/Daniel)			***//
//***             20/06/2018 - Adicionado parametros para a COBTIT  (Luis  Fernando (GFT)   ***//
//*********************************************************************************************//

var cCddopcao;
var cCdcooper;
var cTpproduto;
var frmCab = 'frmCab';
var frmTab096 = 'frmTab096';
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
    $('#'+frmCab).css("width",'840px');
    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);

    var cddopcao = $("#cddopcao", "#frmCab").val();

    var rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    var rCdcooper = $('label[for="cdcooper"]', '#frmCab');
    var rTpproduto = $('label[for="tpproduto"]', '#frmCab');

    rCddopcao.css('width', '50px').addClass('rotulo');
    rCdcooper.css('width', '70px').addClass('rotulo-linha');
    rTpproduto.css('width', '70px').addClass('rotulo-linha');

    cCddopcao = $('#cddopcao', '#frmCab');
    cCddopcao.css('width', '330px');

    cTpproduto = $('#tpproduto', '#frmCab');

    cCdcooper = $('#cdcooper', '#frmCab');
    cCdcooper.html(slcooper);
    cCdcooper.css('width', '125px').attr('maxlength', '2');

    cCddopcao.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 13 || e.keyCode == 9 || e.KeyCode == 18) {
            cCdcooper.focus();
            return false;
        }
    });

    cCddopcao.unbind('changed').bind('changed', function(e) {
        cCdcooper.focus();
        return false;
    });

    cCdcooper.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 13) {
            cTpproduto.focus();
            return false;
        }
    });

    cCdcooper.unbind('changed').bind('changed', function(e) {
        cTpproduto.focus();
        return false;
    });

    cTpproduto.unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 13) {
        controlaOperacao();
            return false;
        }
    });

    cTpproduto.unbind('changed').bind('changed', function(e) {
        controlaOperacao();
        return false;
    });

}

function formataFormulario() {

    cTodosFormulario = $('input[type="text"],input[type="checkbox"],select', '#frmTab096');

    highlightObjFocus($('#frmTab096'));

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var cdcooper = $("#cdcooper", "#frmCab").val();

    var rNrconven = $('label[for="nrconven"]', '#frmTab096');
    var rNrdconta = $('label[for="nrdconta"]', '#frmTab096');
    var rPrazomax = $('label[for="prazomax"]', '#frmTab096');
    var rPrazobxa = $('label[for="prazobxa"]', '#frmTab096');
    var rVlrminpp = $('label[for="vlrminpp"]', '#frmTab096');
    var rVlrmintr = $('label[for="vlrmintr"]', '#frmTab096');
    var rVlrminpos = $('label[for="vlrminpos"]', '#frmTab096');
    var rDescprej = $('label[for="descprej"]', '#frmTab096');
    var rLinha1 = $('label[for="dslinha1"]', '#frmTab096');
    var rLinha2 = $('label[for="dslinha2"]', '#frmTab096');
    var rLinha3 = $('label[for="dslinha3"]', '#frmTab096');
    var rLinha4 = $('label[for="dslinha4"]', '#frmTab096');
    var rDstxtsms = $('label[for="dstxtsms"]', '#frmTab096');
    var rDstxtema = $('label[for="dstxtema"]', '#frmTab096');
    var rBlqemiss = $('label[for="blqemiss"]', '#frmTab096');
    var rEmissnpg = $('label[for="emissnpg"]', '#frmTab096');
    var rQtdmaxbl = $('label[for="qtdmaxbl"]', '#frmTab096');
    var rFlgblqvl = $('label[for="flgblqvl"]', '#frmTab096');
	
	rNrconven.addClass('rotulo').css('width','320px');
	rNrdconta.addClass('rotulo').css('width','320px');
	rPrazomax.addClass('rotulo').css('width','320px');
	rPrazobxa.addClass('rotulo').css('width','320px');
	rVlrminpp.addClass('rotulo').css('width','320px');
	rVlrmintr.addClass('rotulo').css('width','320px');
    rVlrminpos.addClass('rotulo').css('width','320px');
	rDescprej.addClass('rotulo').css('width','320px');
	rLinha1.addClass('rotulo').css('width','200px');
    rLinha2.addClass('rotulo').css('width','200px');
    rLinha3.addClass('rotulo').css('width','200px');
    rLinha4.addClass('rotulo').css('width','200px');
	rBlqemiss.addClass('rotulo').css('width','320px');
	rQtdmaxbl.addClass('rotulo').css('width','320px');
	rFlgblqvl.addClass('rotulo').css('width','320px');


    var cNrconven = $('#nrconven', '#frmTab096');
    var cNrdconta = $('#nrdconta', '#frmTab096');
    var cPrazomax = $('#prazomax', '#frmTab096');
    var cPrazobxa = $('#prazobxa', '#frmTab096');
    var cVlrminpp = $('#vlrminpp', '#frmTab096');
    var cVlrmintr = $('#vlrmintr', '#frmTab096');
    var cVlrminpos = $('#vlrminpos', '#frmTab096');
    var cDescprej = $('#descprej', '#frmTab096');
    var cLinha1 = $('#dslinha1', '#frmTab096');
    var cLinha2 = $('#dslinha2', '#frmTab096');
    var cLinha3 = $('#dslinha3', '#frmTab096');
    var cLinha4 = $('#dslinha4', '#frmTab096');
    var cDstxtsms = $('#dstxtsms', '#frmTab096');
    var cDstxtema = $('#dstxtema', '#frmTab096');
    var cBlqemiss = $('#blqemiss', '#frmTab096');
    var cEmissnpg = $('#emissnpg', '#frmTab096');
    var cQtdmaxbl = $('#qtdmaxbl', '#frmTab096');
    var cFlgblqvl = $('#flgblqvl', '#frmTab096');

    cNrconven.css('width', '300px');
    cNrdconta.css('width', '127px').addClass('conta');
    cPrazomax.css('width', '127px').addClass('inteiro').attr('maxlength','2');
    cPrazobxa.css('width', '127px').addClass('inteiro').attr('maxlength','2');
    cVlrminpp.css('width', '127px').addClass('moeda');
    cVlrmintr.css('width', '127px').addClass('moeda');
    cVlrminpos.css('width', '127px').addClass('moeda');
    cDescprej.css('width', '127px').addClass('moeda');
    cLinha1.css('width', '500px').addClass('alphanum').attr('maxlength','50');
    cLinha2.css('width', '500px').addClass('alphanum').attr('maxlength','50');
    cLinha3.css('width', '500px').addClass('alphanum').attr('maxlength','50');
    cLinha4.css('width', '500px').addClass('alphanum').attr('maxlength','50');
    cDstxtsms.css('width', '776px').addClass('alphanum').attr('maxlength','200');
    cDstxtema.css('width', '776px').addClass('alphanum').attr('maxlength','1000');
    cBlqemiss.css('width', '30px').addClass('inteiro').attr('maxlength','2');
    cEmissnpg.css('width', '30px').addClass('inteiro').attr('maxlength','2');
    cQtdmaxbl.css('width', '60px').addClass('inteiro').attr('maxlength','2');
    cFlgblqvl.css('width', '60px');



    if (cddopcao == "C") {

        cTodosFormulario.desabilitaCampo();
        cDstxtsms.attr("disabled", "disabled");
        cDstxtema.attr("disabled", "disabled");
        $('#divMsgAjuda').css('display', 'block');
        $('#btVoltar', '#divMsgAjuda').show();
        $("#btAlterar", "#divMsgAjuda").hide();
        $('#cddopcao', '#frmCab').focus();

    } else {

        cTodosFormulario.habilitaCampo();
        cDstxtsms.attr("enabled", "enabled");
        cDstxtema.attr("enabled", "enabled");
		
        if (cdcooper == 0) {
            cNrconven.desabilitaCampo();
            cNrdconta.desabilitaCampo();
        }
		
        $('#divMsgAjuda').css('display', 'block');
        $('#btVoltar', '#divMsgAjuda').show();
        $("#btAlterar", "#divMsgAjuda").show();        

		cTodosFormulario.bind('cut copy paste', function(e) {
			e.preventDefault();
		}); 
		
        cNrconven.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cNrdconta.focus();
                return false;
            }
        });

        cNrdconta.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cPrazomax.focus();
                return false;
            }
        });

        cPrazomax.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cPrazobxa.focus();
                return false;
            }
        });

        cPrazobxa.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cVlrminpp.focus();
                return false;
            }
        });

        cVlrminpp.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cVlrmintr.focus();
                return false;
            }
        });

        cVlrmintr.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cVlrminpos.focus();
                return false;
            }
        });

        cVlrminpos.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cDescprej.focus();
                return false;
            }
        });

        cDescprej.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cLinha1.focus();
                return false;
            }
        });

        cLinha1.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cLinha2.focus();
                return false;
            }
        });

        cLinha2.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cLinha3.focus();
                return false;
            }
        });

        cLinha3.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cLinha4.focus();
                return false;
            }
        });

        cLinha4.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cDstxtsms.focus();
                return false;
            }
        });

        cDstxtsms.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cDstxtema.focus();
                return false;
            }
        });

        cDstxtema.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cBlqemiss.focus();
                return false;
            }
        });

        cBlqemiss.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cEmissnpg.focus();
                return false;
            }
        });

        cEmissnpg.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                cQtdmaxbl.focus();
                return false;
            }
        });

        cQtdmaxbl.keypress(function(e) {
            if (e.keyCode == 13 || e.keyCode == 09 || e.keyCode == 18) {
                alterarDados();
                return false;
            }
        });
    }

    $('#frmTab096').css('display', 'block');
    return false;
}

// Botao Voltar
function btnVoltar() {
    estadoInicial();
    return false;
}

function controlaOperacao() {
	
	
    if ($('#cddopcao', '#frmCab').hasClass('campoTelaSemBorda')) {
        return false;
    }

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var cdcooper = $('#cdcooper', '#frmCab').val();
    var tpproduto = $('#tpproduto', '#frmCab').val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/tab096/obtem_consulta.php",
        data: {
            cdcooper: cdcooper,
            cddopcao: cddopcao,
            tpproduto: tpproduto,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#cddopcao','#frmCab').focus()");
        },
        success: function(response) {
            $('#divFormulario').html(response);
            formataFormulario();
            layoutPadrao();
			cTodosCabecalho.desabilitaCampo();
			
			if ($('#cddopcao', '#frmCab').val() == 'A') {

				if ($('#cdcooper', '#frmCab').val() == 0) {
					$('#prazomax', '#frmTab096').focus();
				} else {
					$('#nrconven', '#frmTab096').focus();
				}
			}
			
			hideMsgAguardo();
		
		}

    });

    return false;

}

function alterarDados() {

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var descprej = converteMoedaFloat($('#descprej', '#frmTab096').val());

    if (cddopcao == "A") {
        if (descprej < 0 || descprej > 100) {
            showError("error", "Informe um percentual entre 0 e 100.", "Alerta - Ayllos", "$('#descprej','#frmTab096').focus()");
        } else {
            showConfirmacao('Confirma a atualiza&ccedil;&atilde;o dos parametros?', 'Tab096', 'grava_dados();', 'voltaDiv();estadoInicial();', 'sim.gif', 'nao.gif');
        }
    }
}

function grava_dados() {

    var nrconven = $('#nrconven', '#frmTab096').val();
    var nrdconta = $('#nrdconta', '#frmTab096').val();
    var prazomax = $('#prazomax', '#frmTab096').val();
    var prazobxa = $('#prazobxa', '#frmTab096').val();
    var vlrminpp = $('#vlrminpp', '#frmTab096').val();
    var vlrmintr = $('#vlrmintr', '#frmTab096').val();
    var vlrminpos = $('#vlrminpos', '#frmTab096').val();
    var descprej = $('#descprej', '#frmTab096').val();
    var dslinha1 = $('#dslinha1', '#frmTab096').val();
    var dslinha2 = $('#dslinha2', '#frmTab096').val();
    var dslinha3 = $('#dslinha3', '#frmTab096').val();
    var dslinha4 = $('#dslinha4', '#frmTab096').val();
    var dstxtsms = $('#dstxtsms', '#frmTab096').val();
    var dstxtema = $('#dstxtema', '#frmTab096').val();
    var blqemiss = $('#blqemiss', '#frmTab096').val();
    var emissnpg = $('#emissnpg', '#frmTab096').val();
    var qtdmaxbl = $('#qtdmaxbl', '#frmTab096').val();
    var flgblqvl = $('#flgblqvl', '#frmTab096').val();
    var cdcooper = $("#cdcooper", "#frmCab").val();
    var tpproduto = $("#tpproduto", "#frmCab").val();
	
	nrdconta = normalizaNumero(nrdconta);
	nrconven = normalizaNumero(nrconven);

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/tab096/grava_dados.php",
        data: {
            nrconven: nrconven,
            nrdconta: nrdconta,
            prazomax: prazomax,
            prazobxa: prazobxa,
            vlrminpp: vlrminpp,
            vlrmintr: vlrmintr,
            vlrminpos: vlrminpos,
            descprej: descprej,
            dslinha1: dslinha1,
            dslinha2: dslinha2,
            dslinha3: dslinha3,
            dslinha4: dslinha4,
            dstxtsms: dstxtsms,
            dstxtema: dstxtema,
            blqemiss: (blqemiss + ";" + emissnpg),
            qtdmaxbl: qtdmaxbl,
            flgblqvl: flgblqvl,
            cdcoopex: cdcooper,
            tpproduto: tpproduto,
            redirect: "script_ajax" // Tipo de retorno do ajax
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

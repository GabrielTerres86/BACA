//*********************************************************************************************//
//*** Fonte: coninc.js                                                 						***//
//*** Autor: Jaison Fernando                                           						***//
//*** Data : Novembro/2016                  Última Alteração: --/--/----  					***//
//***                                                                  						***//
//*** Objetivo  : Biblioteca de funções da tela CONINC              						***//
//***                                                                  						***//	 
//*** Alterações: 																			***//
//*********************************************************************************************//

var cCddopcao, cDtrefini, cDtreffim, cDsoperac, cCdcooper, cIddgrupo, cBtngrupo, cNmdgrupo, cDsincons, cDsregist, cTodosCabecalho;
var rCddopcao, rDtrefini, rDtreffim, rDsoperac, rCdcooper, rIddgrupo, rDsincons, rDsregist;
var glbIddgrupo;

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
    
    // Reinicializa os campos
    resetaValores();

    return false;
}

function formataCabecalho() {

    cTodosCabecalho = $('input[type="text"],select', '#frmCab');

    rCddopcao = $('label[for="cddopcao"]', '#frmCab');
    rDsoperac = $('label[for="dsoperac"]', '#frmCab');
    rCdcooper = $('label[for="cdcooper"]', '#frmCab');
    rIddgrupo = $('label[for="iddgrupo"]', '#frmCab');
    rDtrefini = $('label[for="dtrefini"]', '#frmCab');
    rDtreffim = $('label[for="dtreffim"]', '#frmCab');
    rDsincons = $('label[for="dsincons"]', '#frmCab');
    rDsregist = $('label[for="dsregist"]', '#frmCab');

    rCddopcao.css('width', '50px').addClass('rotulo');
    rDsoperac.css('width', '77px').addClass('rotulo-linha').hide();
    rCdcooper.css('width', '83px').addClass('rotulo-linha').hide();
    rIddgrupo.css('width', '60px').addClass('rotulo-linha').hide();
    rDtrefini.css('width', '60px').addClass('rotulo-linha').hide();
    rDtreffim.css('width', '25px').addClass('rotulo-linha').hide();
    rDsincons.css('width', '104px').addClass('rotulo-linha').hide();
    rDsregist.css('width', '150px').addClass('rotulo-linha').hide();

    cCddopcao = $('#cddopcao', '#frmCab');
    cDsoperac = $('#dsoperac', '#frmCab');
    cCdcooper = $('#cdcooper', '#frmCab');
    cIddgrupo = $('#iddgrupo', '#frmCab');
    cBtngrupo = $('#btngrupo', '#frmCab');
    cNmdgrupo = $('#nmdgrupo', '#frmCab');
    cDtrefini = $('#dtrefini', '#frmCab');
    cDtreffim = $('#dtreffim', '#frmCab');
    cDsincons = $('#dsincons', '#frmCab');
    cDsregist = $('#dsregist', '#frmCab');

    cCddopcao.css('width', '565px');
    cDsoperac.css('width', '100px').hide();
    cCdcooper.css('width', '100px').hide();
    cIddgrupo.css('width', '50px').hide().setMask('INTEGER', 'zzzzz', '', '');
    cBtngrupo.hide();
    cNmdgrupo.css('width', '308px').hide();
    cDtrefini.css('width', '73px').hide().setMask("DATE","","","");
    cDtreffim.css('width', '73px').hide().setMask("DATE","","","");
    cDsincons.css('width', '185px').hide();
    cDsregist.css('width', '185px').hide();

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

function ativaCampoCabecalho() {

	cCddopcao.desabilitaCampo();
    cDtrefini.val(glb_dtmvtolt);
    cDtreffim.val(glb_dtmvtolt);
    $('#btnOK','#frmCab').hide();

    trocaBotao('Prosseguir','controlaOperacao(1,30)','btnVoltar()');

    // Remove a opcao Alterar
    $("#dsoperac option[value='A']").remove();

    if (glb_cdcooper != 3) {
        cCdcooper.desabilitaCampo();
    }

    cIddgrupo.bind('keydown', function (e) {
        var keyValue = getKeyValue(e);
        if (keyValue == 118) { // Se for F7
            mostraPesquisaGrupo();
        }
    });

    cIddgrupo.unbind('blur').bind('blur', function(e) {		
         carregaDadosGrupo();
    });

    switch (cCddopcao.val()) {

        case 'C':
            cCddopcao.css('width', '350px');
            rDtrefini.show();
            cDtrefini.show().focus();
            rDtreffim.show();
            cDtreffim.show();
            rCdcooper.show();
            cCdcooper.show();
            rIddgrupo.show();
            cIddgrupo.show();
            cBtngrupo.show();
            cNmdgrupo.show().desabilitaCampo();
            rDsincons.show();
            cDsincons.show();
            rDsregist.show();
            cDsregist.show();

            cDtrefini.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    cDtreffim.focus();
                    return false;
                }
            });

            cDtreffim.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    if (glb_cdcooper == 3) {
                        cCdcooper.focus();
                    } else {
                        cIddgrupo.focus();
                    }
                    return false;
                }
            });

            cCdcooper.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    cIddgrupo.focus();
                    return false;
                }
            });

            cIddgrupo.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    carregaDadosGrupo();
                    cDsincons.focus();
                    return false;
                }
            });

            cDsincons.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    cDsregist.focus();
                    return false;
                }
            });

            cDsregist.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    controlaOperacao(1,30);
                    return false;
                }
            });
            break;

        case 'G':
            // Inclui a opcao Alterar
            $("#dsoperac option").eq(2).before($('<option>', {
                value: 'A',
                text: 'Alterar'
            }));

            cCddopcao.css('width', '400px');
            rDsoperac.show();
            cDsoperac.show().focus();

            cDsoperac.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    controlaOperacao(1,30);
                    return false;
                }
            });
            break;

        case 'E':
        case 'A':
            trocaBotao('Prosseguir','carregaDadosGrupo()','btnVoltar()');
            cCddopcao.css('width', '400px');
            rDsoperac.show();
            cDsoperac.show().focus();
            rCdcooper.show();
            cCdcooper.show();
            rIddgrupo.show();
            cIddgrupo.show();
            cBtngrupo.show();
            cNmdgrupo.show().desabilitaCampo();

            cDsoperac.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    if (glb_cdcooper == 3) {
                        cCdcooper.focus();
                    } else {
                        cIddgrupo.focus();
                    }
                    return false;
                }
            });

            cCdcooper.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    cIddgrupo.focus();
                    return false;
                }
            });

            cIddgrupo.unbind('keypress').bind('keypress', function(e) {
                if (e.keyCode == 13 || e.keyCode == 9) {
                    carregaDadosGrupo();
                    return false;
                }
            });
            break;

    }

    return false;

}

function trocaBotao( botao,funcao,funcaoVoltar ) {
	
	$('#divBotoes','#divTela').html('');
	$('#divBotoes','#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="'+funcaoVoltar+'; return false;">Voltar<a/>');
	
	if ( botao != '') {
		$('#divBotoes','#divTela').append('&nbsp;<a href="#" class="botao" id="btSalvar" onClick="'+funcao+'; return false;">'+botao+'</a>');
	}
	
	return false;
	
}

function controlaOperacao(nriniseq, nrregist) {

    if (cCddopcao.val() == 'C') {

        if (cDtrefini.val() == '') {
            showError("error", "Informe a data.", "Alerta - Ayllos", "cDtrefini.focus()");
            return false;
        }

        if (cDtreffim.val() == '') {
            showError("error", "Informe a data.", "Alerta - Ayllos", "cDtreffim.focus()");
            return false;
        }

    }

    if ((cCddopcao.val() == 'C' || cCddopcao.val() == 'E' || cCddopcao.val() == 'A') && normalizaNumero(cIddgrupo.val()) == 0) {
        showError("error", "Informe o grupo.", "Alerta - Ayllos", "cIddgrupo.val('').focus()");
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        dataType: 'html',
        url: UrlSite + "telas/coninc/obtem_consulta.php",
        data: {
            nriniseq: nriniseq,
            nrregist: nrregist,
            cddopcao: cCddopcao.val(),
            dtrefini: cDtrefini.val(),
            dtreffim: cDtreffim.val(),
            dsoperac: cDsoperac.val(),
            cdcooper: cCdcooper.val(),
            iddgrupo: cIddgrupo.val(),
            dsincons: cDsincons.val(),
            dsregist: cDsregist.val(),
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

function grava_dados() {

    var iddgrup2 = normalizaNumero($('#iddgrup2', '#frmOpcaoG').val());
    var nmdgrupo = $('#nmdgrupo', '#frmOpcaoG').val();
    var indconte = $('#indconte', '#frmOpcaoG').val();
    var dsassunt = $('#dsassunt', '#frmOpcaoG').val();
    var indperio = $('#indperio', '#frmOpcaoG').val();

    var vlcampos = '';
    if (cCddopcao.val() == 'E' || cCddopcao.val() == 'A') { // E-mail ou Acesso
        if (cDsoperac.val() == 'I') { // Incluir
            vlcampos = cCdcooper.val() + '_' + cIddgrupo.val() + '_' + $('#' + (cCddopcao.val() == 'E' ? 'dsdemail' : 'cddepart'), '#frmOpcao' + cCddopcao.val()).val();
        } else if (cDsoperac.val() == 'E'){ // Excluir
            $("input:checked").each(function () {
                vlcampos += (vlcampos == '' ? '' : '#') + $(this).attr("id");
            });
        }
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, enviando informa&ccedil;&otilde;es ...");

    // Carrega conteúdo da opção através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/coninc/grava_dados.php",
        data: {
            cddopcao : cCddopcao.val(),
            dsoperac : cDsoperac.val(),
            cdcooper : cCdcooper.val(),
            iddgrupo : normalizaNumero(cIddgrupo.val()),

            // OPCAO G
            iddgrup2 : iddgrup2,
            nmdgrupo : nmdgrupo,
            indconte : indconte,
            dsassunt : dsassunt,
            indperio : indperio,
            
            // OPCAO A / OPCAO E
            vlcampos : vlcampos,

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

function formataGridInconsistencia() {
	
    var divRegistro = $('#divInconsistencia');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'200px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '100px';
    arrayLargura[1] = '40px';
    arrayLargura[2] = '100px';
    arrayLargura[3] = '190px';

    var arrayAlinha = new Array();

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);
    return false;	
}

function formataGridGrupo() {
	
    var divRegistro = $('#divGrupo');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'200px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    arrayLargura[0] = '80px';
    arrayLargura[1] = '200px';
    arrayLargura[2] = '200px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[3] = 'center';

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

	// Seleciona o registro que foi clicado
	$('table > tbody > tr', divRegistro).click( function() {
		glbIddgrupo = $(this).find('#hd_iddgrupo').val();
	});

    $('table > tbody > tr:eq(0)', divRegistro).click();

    return false;	
}

function formataGridEmail() {
	
    var divRegistro = $('#divEmail');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'200px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    var arrayAlinha = new Array();
    
    if (cDsoperac.val() == 'E') { // Se for exclusao
        arrayLargura[0] = '20px';
        arrayLargura[1] = '100px';

        arrayAlinha[0] = 'center';
    } else {
        arrayLargura[0] = '100px';
    }

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

    return false;	
}

function formataGridAcesso() {
	
    var divRegistro = $('#divAcesso');
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    divRegistro.css({'height':'200px'});

    var ordemInicial = new Array();
    ordemInicial = [[0,0]];

    var arrayLargura = new Array();
    var arrayAlinha = new Array();
    
    if (cDsoperac.val() == 'E') { // Se for exclusao
        arrayLargura[0] = '20px';
        arrayLargura[1] = '100px';

        arrayAlinha[0] = 'center';
    } else {
        arrayLargura[0] = '100px';
    }

    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha);

    return false;	
}

function formataFormGrupo() {

    highlightObjFocus($('#frmOpcaoG'));

    var cIddgrup2 = $('#iddgrup2', '#frmOpcaoG');
    var cNmdgrupo = $('#nmdgrupo', '#frmOpcaoG');
    var cIndconte = $('#indconte', '#frmOpcaoG');
    var cDsassunt = $('#dsassunt', '#frmOpcaoG');
    var cIndperio = $('#indperio', '#frmOpcaoG');

    cIddgrup2.addClass('campo').css('width', '80px').desabilitaCampo();
    cNmdgrupo.addClass('campo').css('width', '200px').attr('maxlength','100').focus();
    cIndconte.addClass('campo').css('width', '200px');
    cDsassunt.addClass('campo').css('width', '200px').attr('maxlength','500');
    cIndperio.addClass('campo').css('width', '200px');

    cNmdgrupo.keypress(function(e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            cIndconte.focus();
            return false;
        }
    });

    cIndconte.keypress(function(e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            cDsassunt.focus();
            return false;
        }
    });

    cDsassunt.keypress(function(e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            cIndperio.focus();
            return false;
        }
    });

    cIndperio.keypress(function (e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            confirmaOperacao();
            return false;
        }
    });

    return false;
}

function formataFormEmail() {

    highlightObjFocus($('#frmOpcaoE'));

    var cDsdemail = $('#dsdemail', '#frmOpcaoE');
    cDsdemail.addClass('campo').css('width', '350px').focus();

    cDsdemail.keypress(function (e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            confirmaOperacao();
            return false;
        }
    });

    return false;
}

function formataFormAcesso() {

    highlightObjFocus($('#frmOpcaoA'));

    var cCddepart = $('#cddepart', '#frmOpcaoA');
    cCddepart.addClass('campo').css('width', '350px').focus();

    cCddepart.keypress(function (e) {
        if (e.keyCode == 13 || e.keyCode == 09) {
            confirmaOperacao();
            return false;
        }
    });

    return false;
}

function confirmaOperacao() {

    // Se for exclusao de Email ou de Acesso
    if ((cCddopcao.val() == 'E' || cCddopcao.val() == 'A') && cDsoperac.val() == 'E') {
        if ($("input:checked").prop("checked") != true) {
            showError("error", "Marque ao menos uma opção.", "Alerta - Ayllos");
            return false;
        }
    }

    if (cCddopcao.val() == 'G') {
        if ($('#nmdgrupo', '#frmOpcaoG').val() == '') {
            showError("error", "Informe a descrição.", "Alerta - Ayllos","$('#nmdgrupo', '#frmOpcaoG').focus()");
            return false;
        }
        if ($('#dsassunt', '#frmOpcaoG').val() == '') {
            showError("error", "Informe o título.", "Alerta - Ayllos","$('#dsassunt', '#frmOpcaoG').focus()");
            return false;
        }
        // Se for exclusao
        if(cDsoperac.val() == 'E') {
            selecionaRegistro();
        }
    } else if (cCddopcao.val() == 'E') {
        if ($('#dsdemail', '#frmOpcaoE').val() == '') {
            showError("error", "Informe o e-mail.", "Alerta - Ayllos","$('#dsdemail', '#frmOpcaoE').focus()");
            return false;
        }        
    } else if (cCddopcao.val() == 'A') {
        if ($('#cddepart', '#frmOpcaoA').val() == '') {
            showError("error", "Informe o departamento.", "Alerta - Ayllos","$('#cddepart', '#frmOpcaoA').focus()");
            return false;
        }        
    }

    var dsmensag = '';

    if (cDsoperac.val() == 'A') {
        dsmensag = 'altera&ccedil;&atilde;o';
    } else if (cDsoperac.val() == 'E') {
        dsmensag = 'exclus&atilde;o';
    } else if (cDsoperac.val() == 'I') {
        dsmensag = 'inclus&atilde;o';
    }

    showConfirmacao('Confirma ' + dsmensag + '?', 'CONINC', 'grava_dados()', '', 'sim.gif', 'nao.gif');
}

function resetaValores() {
    cIddgrupo.val('');
    cNmdgrupo.val('');
}

function resetaCamposGrupo() {
    resetaValores();
    cIddgrupo.focus();
}

function selecionaRegistro() {
    cIddgrupo.val(glbIddgrupo);
}

function carregaAlteracao() {
    selecionaRegistro()
    controlaOperacao(1,30);
}

function btnVoltarOpcaoG() {
    resetaValores();
    controlaOperacao(1,30);
    return false;
}

function mostraPesquisaGrupo() {
    var bo, procedure, titulo, qtReg, filtros, colunas;
    
    bo			= 'TELA_CONINC'; 
	procedure	= 'CONINC_PESQUISA_GRUPO';
	titulo      = 'Grupos';
	qtReg		= '30';
    filtros 	= 'Codigo;iddgrupo;80px;S;;S|Descricao;nmdgrupo;280px;S;;S|;cdcooper;;N;'+ cCdcooper.val() +';N|;cddopcao;;N;'+ cCddopcao.val() +';N';
	colunas 	= 'Codigo;iddgrupo;20%;right|Grupo;nmdgrupo;40%;left';

    mostraPesquisa(bo,procedure,titulo,qtReg,filtros,colunas);
	return false;
}

function carregaDadosGrupo() {
	if (normalizaNumero(cIddgrupo.val()) > 0) {
        $.ajax({
            type: "POST",
            dataType: 'html',
            url: UrlSite + "telas/coninc/busca_dados_grupo.php",
            data: {
                cddopcao : cCddopcao.val(),
                cdcooper : cCdcooper.val(),
                iddgrupo : cIddgrupo.val(),
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

function exportaInconsistencia() {

    var nomeform = 'frmExporta';

    $('#sidlogin', '#' + nomeform).remove();

    $('#cddopcao1', '#' + nomeform).remove();
    $('#cdcooper1', '#' + nomeform).remove();
    $('#iddgrupo1', '#' + nomeform).remove();
    $('#dtrefini1', '#' + nomeform).remove();
    $('#dtreffim1', '#' + nomeform).remove();
    $('#dsincons1', '#' + nomeform).remove();
    $('#dsregist1', '#' + nomeform).remove();

    // Insere input do tipo hidden do formulario para envia-los posteriormente
    $('#' + nomeform).append('<input type="text" id="cddopcao1" name="cddopcao1" />');
    $('#' + nomeform).append('<input type="text" id="cdcooper1" name="cdcooper1" />');
    $('#' + nomeform).append('<input type="text" id="iddgrupo1" name="iddgrupo1" />');
    $('#' + nomeform).append('<input type="text" id="dtrefini1" name="dtrefini1" />');
    $('#' + nomeform).append('<input type="text" id="dtreffim1" name="dtreffim1" />');
    $('#' + nomeform).append('<input type="text" id="dsincons1" name="dsincons1" />');
    $('#' + nomeform).append('<input type="text" id="dsregist1" name="dsregist1" />');

    $('#' + nomeform).append('<input type="text" id="sidlogin" name="sidlogin" />');

    // Agora insiro os devidos valores nos inputs criados
    $('#cddopcao1', '#' + nomeform).val(cCddopcao.val());
    $('#cdcooper1', '#' + nomeform).val(cCdcooper.val());
    $('#iddgrupo1', '#' + nomeform).val(cIddgrupo.val());
    $('#dtrefini1', '#' + nomeform).val(cDtrefini.val());
    $('#dtreffim1', '#' + nomeform).val(cDtreffim.val());
    $('#dsincons1', '#' + nomeform).val(cDsincons.val());
    $('#dsregist1', '#' + nomeform).val(cDsregist.val());

    $('#sidlogin', '#' + nomeform).val($('#sidlogin', '#frmMenu').val());

    var action = UrlSite + 'telas/coninc/csv.php';

    // Variavel para os comandos de controle
    var controle = '';

    carregaImpressaoAyllos(nomeform, action, controle);

    return false;
}

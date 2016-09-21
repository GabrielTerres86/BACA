/*!
 * FONTE        : indice.js
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 29/04/2014
 * OBJETIVO     : Biblioteca de funções da tela INDICE
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 */

//Formulários    
var frmCab = 'frmCab';

var rCddopcao, rCddindexA, rCddindexC, rCddindexT, rNmdindex, rIdperiodI, rIdperiodA, rIdexpresA, rIdexpresI, rIdcadastA, rIdcadastI, rVlrdtaxa, rDtperiod, rDtiniperAno, rDtfimperAno, rDtiniperMes, rDtfimperMes;
var cCddopcao, cCddindexA, cCddindexC, cCddindexT, cNmdindex, cIdperiodI, cIdperiodA, cIdexpresA, cIdexpresI, cIdcadastA, cIdcadastI, cVlrdtaxa, cDtperiod, cDtiniperAno, cDtfimperAno, cDtiniperMes, cDtfimperMes;
var btnSalvar, btnOK, divAno, divMes, divDia;

var auxMTaxas = 'I';
var flgAltera = 0;

var glb_nriniseq = 1;  /* Numero inicial da listagem de registros, opcao C e R */
var glb_nrregist = 20; /* Numero de registros por pagina, opcao C e R */

$(document).ready(function() {

    divAno = $('#dtPeriodAno', '#' + frmCab);
    divMes = $('#dtPeriodMes', '#' + frmCab);

    //Labels
    rCddopcao = $('label[for="cddopcao"]', '#' + frmCab);
    rNmdindex = $('label[for="nmdindex"]', '#' + frmCab);
    rVlrdtaxa = $('label[for="vlrdtaxa"]', '#' + frmCab);
    rDtperiod = $('label[for="dtperiod"]', '#' + frmCab);

    rDtiniperAno = $('label[for="dtiniperAno"]', '#' + frmCab);
    rDtfimperAno = $('label[for="dtfimperAno"]', '#' + frmCab);
    rDtiniperMes = $('label[for="dtiniperMes"]', '#' + frmCab);
    rDtfimperMes = $('label[for="dtfimperMes"]', '#' + frmCab);

    rCddindexA = $('label[for="cddindexA"]', '#' + frmCab);
    rCddindexC = $('label[for="cddindexC"]', '#' + frmCab);
    rCddindexT = $('label[for="cddindexT"]', '#' + frmCab);
    rIdperiodI = $('label[for="idperiodI"]', '#' + frmCab);
    rIdperiodA = $('label[for="idperiodA"]', '#' + frmCab);
    rIdexpresA = $('label[for="idexpresA"]', '#' + frmCab);
    rIdexpresI = $('label[for="idexpresI"]', '#' + frmCab);
    rIdcadastA = $('label[for="idcadastA"]', '#' + frmCab);
    rIdcadastI = $('label[for="idcadastI"]', '#' + frmCab);

    //Campos
    cDtiniperAno = $('#dtiniperAno', '#' + frmCab);
    cDtfimperAno = $('#dtfimperAno', '#' + frmCab);
    cDtiniperMes = $('#dtiniperMes', '#' + frmCab);
    cDtfimperMes = $('#dtfimperMes', '#' + frmCab);

    cCddindexA = $('#cddindexA', '#' + frmCab);
    cCddindexC = $('#cddindexC', '#' + frmCab);
    cCddindexT = $('#cddindexT', '#' + frmCab);
    cIdperiodI = $('#idperiodI', '#' + frmCab);
    cIdperiodA = $('#idperiodA', '#' + frmCab);
    cIdexpresA = $('#idexpresA', '#' + frmCab);
    cIdexpresI = $('#idexpresI', '#' + frmCab);
    cIdcadastA = $('#idcadastA', '#' + frmCab);
    cIdcadastI = $('#idcadastI', '#' + frmCab);

    cCddopcao = $('#cddopcao', '#' + frmCab);
    cNmdindex = $('#nmdindex', '#' + frmCab);
    cVlrdtaxa = $('#vlrdtaxa', '#' + frmCab);
    cDtperiod = $('#dtperiod', '#' + frmCab);
    btnSalvar = $('#btSalvar', '#' + frmCab);

    btnOK = $('#btnOK', '#' + frmCab);

    estadoInicial();
    highlightObjFocus($('#' + frmCab));

    $('fieldset > legend').css({'font-size': '11px', 'color': '#777', 'margin-left': '5px', 'padding': '0px 2px'});
    $('fieldset').css({'clear': 'both', 'border': '1px solid #777', 'margin': '3px 0px', 'padding': '10px 3px 5px 3px'});
	
    return false;

});

function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);
    $('#frmCab').css({'display': 'block'});

    formataCabecalho();

    divAno.hide();
    divMes.hide();

    cTodosCabecalho.limpaFormulario();
    controlaFoco();
    removeOpacidade('divTela');
    unblockBackground();
    hideMsgAguardo();

    cCddopcao.val('C');
    $('input,select', '#frmCab').removeClass('campoErro');

}

function formataCabecalho() {

    var caracteresesp = '!@#$%&*()_+=§:<>;/?[]{}°ºª¬¢£,.´`¨^~¨¹²³£¬§&\'\"\\|';
    var caracteresespDec = '!@#$%&*()_+=§:<>/?[]{}°ºª¬¢£´`¨^~¨¹²³£¬§&\'\"\\|';

    cTodosCabecalho = $('input[type="text"],select', '#' + frmCab);

    $('#' + frmCab).css('width', '700px');
    $('#divIndice', '#' + frmCab).css('margin-left', '80px');

    //Labels	
    rCddopcao.css('width', '120px');
    rNmdindex.css('width', '120px');
    rVlrdtaxa.css('width', '120px');
    rDtperiod.css('width', '120px');
    rCddindexA.css('width', '120px');
    rCddindexC.css('width', '120px');
    rCddindexT.css('width', '120px');
    rIdperiodI.css('width', '120px');
    rIdperiodA.css('width', '120px');
    rIdexpresA.css('width', '120px');
    rIdexpresI.css('width', '120px');
    rIdcadastA.css('width', '120px');
    rIdcadastI.css('width', '120px');
    rDtiniperAno.css('width', '120px');
    rDtfimperAno.css('width', '120px');
    rDtiniperMes.css('width', '120px');
    rDtfimperMes.css('width', '120px');

    //Campo
    cVlrdtaxa.css({'width': '100px'});
    cDtperiod.css({'width': '100px'});
    cCddopcao.css({'width': '320px'});
    cNmdindex.css({'width': '320px'});
    cIdperiodI.css({'width': '320px'});
    cIdperiodA.css({'width': '320px'});
    cIdexpresA.css({'width': '320px'});
    cIdexpresI.css({'width': '320px'});
    cCddindexA.css({'width': '320px'});
    cCddindexC.css({'width': '320px'});
    cCddindexT.css({'width': '320px'});

    cDtiniperAno.css({'width': '60px'});
    cDtfimperAno.css({'width': '60px'});
    cDtiniperMes.css({'width': '60px'});
    cDtfimperMes.css({'width': '60px'});

    cTodosCabecalho.habilitaCampo();

    cVlrdtaxa.css('text-align', 'right');
    cNmdindex.setMask('STRING', 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ', caracteresesp);

    $('#cddopcao', '#' + frmCab).focus();
    rCddopcao.css('margin-left', '80px');
    $('#btSalvar', '#' + frmCab).css('margin-left', '160px');

    cDtiniperAno.attr('readonly', true);
    cDtfimperAno.attr('readonly', true);

    cDtiniperMes.attr('readonly', true);
    cDtfimperMes.attr('readonly', true);

    return false;
}


function btnVoltar() {
	flgAltera = 0;
    $("#divConsulta").hide();

    cCddopcao.attr('disabled', false);

    cCddindexC.attr('disabled', false);
    cCddindexT.attr('disabled', false);
    cCddindexA.attr('disabled', false);

    $("#dtPeriodAno").hide();
    $("#dtPeriodMes").hide();

    limpaTela();

    cCddopcao.val('C');
    cCddindexC.val('');

    cDtiniperAno.val('');
    cDtfimperAno.val('');
    cDtiniperMes.val('');
    cDtfimperMes.val('');

    cCddopcao.focus();
}

function escolheOpcao() {

    var cddopcao = cCddopcao.val();
	
	glb_nriniseq = 1;  /* Numero inicial da listagem de registros, opcao C e R */
	glb_nrregist = 20; /* Numero de registros por pagina, opcao C e R */
	
    cNmdindex.val('');

    cDtiniperAno.empty();
    cDtfimperAno.empty();
    cDtiniperMes.empty();
    cDtfimperMes.empty();

    cVlrdtaxa.val('');
    cDtperiod.val('');
    cIdperiodI.val('');
    cIdperiodA.val('');
    cIdexpresA.val('');
    cIdexpresI.val('');
    cCddindexA.val('');
    cCddindexC.val('');
    cCddindexT.val('');

    //Esconde todas as divs que estão dentro da div pai #divIndice
    $("#divIndice div").each(function(i) {
        $(this).hide();
    });

    //Esconde tabela de resultados de consulta
    $("#divConsulta").hide();

    switch (cddopcao)
    {
        case 'A':
            btnSalvar.empty();
            btnSalvar.html('Prosseguir');
            $("#divAlteracao").show();
            $("#idperiodA", "#" + frmCab).attr("disabled", true);
            $("#idexpresA", "#" + frmCab).attr("disabled", true);
            $("#idcadastA", "#" + frmCab).attr("disabled", true);
            $('input:radio[name=idcadastA][value=1]').attr('checked', true);
            carregaCombo('A');
			cCddindexA.habilitaCampo();
			cCddindexA.focus();
            break;
        case 'C':
            $("#divConsultaRel").show();
            $("#btnConsulta").show();
            $("#btVoltar", "#btnConsulta").attr("onclick", "btnVoltar()");
            carregaCombo('C');
            $("#cddindexC", "#" + frmCab).habilitaCampo();

            $("#dtPeriodAno", "#" + frmCab).hide();
            $("#dtPeriodMes", "#" + frmCab).hide();

            $("#cddindexC", "#" + frmCab).focus();

            break;
        case 'I':
            $("#divInclusao").show();
            $('input:radio[name=idcadastI][value=1]').attr('checked', true);
            carregaCombo('I');
            $("#nmdindex", "#" + frmCab).focus();
            break;
        case 'R':
            $("#divConsultaRel").show();
            $("#btnConsulta").show();
            $("#btVoltar", "#btnConsulta").attr("onclick", "btnVoltar()");
            carregaCombo('R');
			$("#cddindexC", "#" + frmCab).habilitaCampo();
            $("#cddindexC", "#" + frmCab).focus();

            $("#dtPeriodAno", "#" + frmCab).hide();
            $("#dtPeriodMes", "#" + frmCab).hide();

            break;
        case 'T':
            $("#divTaxa").show();
            //Mascara do campo de valor de indexadores
            cVlrdtaxa.addClass('indexador');
            layoutPadrao();
			cCddindexT.habilitaCampo();
			cDtperiod.desabilitaCampo();
            cVlrdtaxa.desabilitaCampo();            
            carregaCombo('T');
            cCddindexT.focus();
            break;
        default:
            $("#divConsultaRel").show();
            break;
    }
    cCddopcao.attr("disabled", "disabled");
    btnOK.hide();
}

function manterRotina() {

    var dtiniper = 0;
    var dtfimper = 0;

    if (cCddopcao.val() == 'A') {
        var idperiod = cIdperiodA.val() == null ? 0 : cIdperiodA.val();
        var idexpres = cIdexpresA.val() == null ? 0 : cIdexpresA.val();
        var idcadast = $('input[name=idcadastA]:checked', '#' + frmCab).val();
    } else {
        var idperiod = cIdperiodI.val() == null ? 0 : cIdperiodI.val();
        var idexpres = cIdexpresI.val() == null ? 0 : cIdexpresI.val();
        var idcadast = $('input[name=idcadastI]:checked', '#' + frmCab).val();
    }

    if (cCddopcao.val() == 'A') {
        cddindex = cCddindexA.val();
    } else if (cCddopcao.val() == 'C' || cCddopcao.val() == 'R') {
        cddindex = cCddindexC.val();
    } else if (cCddopcao.val() == 'T') {
        cddindex = cCddindexT.val();
    } else {
        cddindex = 0;
    }

    if ($("#dtPeriodAno", '#' + frmCab).is(':visible')) {
        dtiniper = cDtiniperAno.val();
        dtfimper = cDtfimperAno.val();
    } else if ($("#dtPeriodMes", '#' + frmCab).is(':visible')) {
        dtiniper = cDtiniperMes.val();
        dtfimper = cDtfimperMes.val();
    }

    showMsgAguardo("Aguarde...");

    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/indice/manter_rotina.php",
        data: {
            cddindex: cddindex,
            idperiod: idperiod,
            idexpres: idexpres,
            idcadast: idcadast,
            cddopcao: cCddopcao.val(),
            nmdindex: cNmdindex.val(),
            dtperiod: cDtperiod.val(),
            dtiniper: dtiniper,
            dtfimper: dtfimper,
            vlrdtaxa: cVlrdtaxa.val(),
			flgalter: flgAltera,
            redirect: "script_ajax"
        },
        success: function(response) {
            hideMsgAguardo();

            if (cCddopcao.val() == 'C') {
                $('#divConsulta').html(response);
                formataTabelaIndice();
            } else if (cCddopcao.val() == 'R') {
				if(response.substr(0,4) == "hide"){
					eval(response);
				}else{
					geraImpressao(response);
				}
            } else {
				eval(response);
            }
        }
    });
}

function msgConfirmacao() {
	
    switch (cCddopcao.val())
    {
        case 'A':
            var idcadast = $('input[name=idcadastA]:checked', '#' + frmCab).val();
            var dscindex = cCddindexA.find('option:selected').text();
			var disabled = $("#idperiodA", "#" + frmCab).prop("disabled");
			
			if(disabled && flgAltera == 0){
				limpaCamposAlteracao();
                cCddindexA.desabilitaCampo();
                cIdperiodA.focus();
			}else{
				if (cCddindexA.val() == '' || cNmdindex.val() == null || idcadast == '' || idcadast == null) {
					showError("error", "Informe os dados corretamente.", "Alerta - Ayllos", "");
					return false;
				}
				showConfirmacao('Confirma altera&ccedil;&atilde;o no indexador ' + dscindex + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina()', '', 'sim.gif', 'nao.gif');
			}

            break;
        case 'C':
            var dscindex = cCddindexC.find('option:selected').text();
            var datVisib = false;
            var dtiniper = 0;
            var dtfimper = 0;
		
			glb_nriniseq = 1;  /* Numero inicial da listagem de registros, opcao C e R */
			glb_nrregist = 20; /* Numero de registros por pagina, opcao C e R */
	
            if ($("#dtPeriodAno", '#' + frmCab).is(':visible')) {
				dtiniper = cDtiniperAno.val();
                dtfimper = cDtfimperAno.val();
                datVisib = true;
            } else if ($("#dtPeriodMes", '#' + frmCab).is(':visible')) {
                dtiniper = cDtiniperMes.val();
                dtfimper = cDtfimperMes.val();
                datVisib = true;
            }

            if (datVisib) {
                if (cCddindexC.val() <= 0 || cCddindexC.val() == '' || cCddindexC.val() == null) {
                    showError("error", "Selecione um indexador para efetuar a consulta.", "Alerta - Ayllos", "");
                    return false;
                } else if (dtiniper == '' || dtiniper == undefined || dtiniper == null) {
                    showError("error", "Informe data de in&iacute;cio do periodo para consulta.", "Alerta - Ayllos", "");
                    return false;
                } else if (dtfimper == '' || dtfimper == undefined || dtfimper == null) {
                    showError("error", "Informe data de fim do periodo para consulta.", "Alerta - Ayllos", "");
                    return false;
                }
                buscaIndice(glb_nriniseq, glb_nrregist);
            } else {
                if (cCddindexC.val() <= 0 || cCddindexC.val() == '' || cCddindexC.val() == null) {
                    showError("error", "Selecione um indexador para efetuar a consulta.", "Alerta - Ayllos", "cCddindexC.focus();");
                    return false;
                } else {
                    cDtiniperAno.val('');
                    cDtfimperAno.val('');
                    cDtiniperMes.val('');
                    cDtfimperMes.val('');
                    consultaTipoData(cCddindexC.val());
                }
            }
            // Quando houver a necessidade de alterar os numero de registros por pagina ou o registro inicial, trocar os valores acima da funcao buscaIndice
            break;
        case 'I':
            var idcadast = $('input[name=idcadastI]:checked', '#' + frmCab).val();

            if (cNmdindex.val() == '' || cNmdindex.val() == null || idcadast == '' || idcadast == null) {
                showError("error", "Informe os dados corretamente.", "Alerta - Ayllos", "");
                return false;
            }
            showConfirmacao('Confirma inclus&atilde;o do novo indexador ' + cNmdindex.val() + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina()', '', 'sim.gif', 'nao.gif');
            break;
        case 'R':
            var dscindex = cCddindexC.find('option:selected').text();
            var dtiniper = 0;
            var dtfimper = 0;
            var datVisib = false;
			
            if ($("#dtPeriodAno", '#' + frmCab).is(':visible')) {
                dtiniper = cDtiniperAno.val();
                dtfimper = cDtfimperAno.val();
                datVisib = true;
            } else if ($("#dtPeriodMes", '#' + frmCab).is(':visible')) {
                dtiniper = cDtiniperMes.val();
                dtfimper = cDtfimperMes.val();
                datVisib = true;
            }
			
            if (datVisib) {
                if (cCddindexC.val() <= 0 || cCddindexC.val() == '' || cCddindexC.val() == null) {
                    showError("error", "Selecione um indexador para efetuar a consulta.", "Alerta - Ayllos", "");
                    return false;
                } else if (dtiniper == '' || dtiniper == undefined || dtiniper == null) {
                    showError("error", "Informe data de in&iacute;cio do periodo para consulta.", "Alerta - Ayllos", "");
                    return false;
                } else if (dtfimper == '' || dtfimper == undefined || dtfimper == null) {
                    showError("error", "Informe data de fim do periodo para consulta.", "Alerta - Ayllos", "");
                    return false;
                }
                showConfirmacao('Confirma gera&ccedil;&atilde;o de relat&oacute;rio do indexador ' + dscindex + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterRotina()', '', 'sim.gif', 'nao.gif');
            } else {
                consultaTipoData(cCddindexC.val());
            }
            break;
        case 'T':
            var dscindex = cCddindexT.find('option:selected').text();

            if (cDtperiod.val() == null || cDtperiod.val() == '') {
                carregaTipoData();
            } else if (cDtperiod.val() == '' || cDtperiod.val() == '00/00/0000' || cDtperiod.val() == '0000' || cDtperiod.val() == '00/0000') {
                showError("error", "Informe uma data de periodo valida.", "Alerta - Ayllos", "cDtperiod.focus();");
                return false;
            } else if (cVlrdtaxa.val() == null || cVlrdtaxa.val() == 0) {
                habilitaTaxa();				
            } else {
                if (auxMTaxas == 'A') {
                    showConfirmacao('Confirma alteracao da taxa do indexador ' + dscindex + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterTaxa("' + auxMTaxas + '");', '', 'sim.gif', 'nao.gif');
                } else {
                    showConfirmacao('Confirma o cadastro da taxa do indexador ' + dscindex + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'manterTaxa("' + auxMTaxas + '");', '', 'sim.gif', 'nao.gif');
                }
            }

            break;
    }
}

function limpaCamposAlteracao() {

    $('#idperiodA', '#frmCab').habilitaCampo();
    $('#idexpresA', '#frmCab').habilitaCampo();
    $('#idcadastA', '#frmCab').habilitaCampo();
    $('input:radio[name=idcadastA][value=1]').attr('checked', true);
    $('input:radio[name=idcadastA][value=2]').attr('checked', false);
    manterRotina();
}

function habilitaTaxa() {

    dtPeriodo = $('#dtperiod', '#frmCab').val();

    if (dtPeriodo != 0 && dtPeriodo != undefined && dtPeriodo != null && dtPeriodo != '') {
        validaData();
        cVlrdtaxa.attr("disabled", false);
        cVlrdtaxa.focus();
    } else {
        showError("error", "Informe a data do per&iacute;odo.", "Alerta - Ayllos", "cDtperiod.focus();");
    }
}

function carregaTipoData() {

    if (cCddindexT.val() == 0 || cCddindexT.val() == null) {
        showError("error", "Informe o indexador.", "Alerta - Ayllos", "cCddindexT.habilitaCampo(); cCddindexT.focus();");
        return false;
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando dados...");

    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/indice/manter_rotina.php",
        data: {
            cddopcao: cCddopcao.val(),
            dtperiod: cDtperiod.val(),
            cddindex: cCddindexT.val(),
			flgalter: flgAltera,
            redirect: "script_ajax"
        },
        success: function(response) {
            hideMsgAguardo();
            eval(response);
            cCddindexT.desabilitaCampo();
        }
    });
}

function controlaFoco() {
	
    $('#cddopcao', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            escolheOpcao();
            return false;
        }
    });

    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            escolheOpcao();
            return false;
        }
    });

    $('#dtperiod', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if (cDtperiod.val() == '' || cDtperiod.val() == '00/00/0000' || cDtperiod.val() == '0000' || cDtperiod.val() == '00/0000') {
                showError("error", "Informe uma data de periodo valida.", "Alerta - Ayllos", "cDtperiod.focus();");
                return false;
            } else {
                validaData();
                return false;
            }
        }
    });

    $('#vlrdtaxa', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#btSalvar', '#frmCab').focus();
            return false;
        }
    });

    /* Opcao de Consulta */
    $('#cddindexC', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if (cCddindexC.val() == 0 || cCddindexC.val() == '') {
                showError("error", "Informe o indexador.", "Alerta - Ayllos", "cCddindexC.focus();");
                return false;
            } else {
                consultaTipoData(cddindexC.val());
                return false;
            }
        }
    });

    /* Fim Opcao de Consulta */

    $('#cddindexT', '#frmCab').unbind('keydown').bind('keydown', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if (cCddindexT.val() == 0 || cCddindexT.val() == null) {
                showError("error", "Informe o indexador.", "Alerta - Ayllos", "cCddindexT.habilitaCampo(); cCddindexT.focus();");
                return false;
            }
            if (e.keyCode == 9) {
                btnSalvar.focus();
                return false;
            } else if (e.keyCode == 13) {
                carregaTipoData();
                return false;
            }

        }
    });
    /* Fim Opcao de Taxa */

    /* Opcao de Inclusao */
    $('#nmdindex', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if (cNmdindex.val() == 0 || cNmdindex.val() == '') {
                showError("error", "Informe o nome do indexador.", "Alerta - Ayllos", "cNmdindex.focus();");
                return false;
            } else {
                cIdperiodI.focus();
                return false;
            }
        }
    });

    $('#idperiodI', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if (cIdperiodI.val() == 0 || cIdperiodI.val() == '') {
                showError("error", "Informe a Periodicidade.", "Alerta - Ayllos", "cIdperiodI.focus();");
                return false;
            } else {
                cIdexpresI.focus();
                return false;
            }
        }
    });

    $('#idexpresI', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            if (cIdperiodI.val() == 0 || cIdperiodI.val() == '') {
                showError("error", "Informe a Taxa Expressa.", "Alerta - Ayllos", "cIdexpresI.focus();");
                return false;
            } else {
                cIdcadastI.focus();
                return false;
            }
        }
    });

    $('#cIdcadastI', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            msgConfirmacao();
            return false;
        }
    });

    /* Fim Opcao de Inclusao */

    /* Opcao de Alteracao */
    $('#cddindexA', '#frmCab').unbind('keydown').bind('keydown', function(e) {
		if (e.keyCode == 9 || e.keyCode == 13) {
			
            if (cCddindexA.val() == 0 || cCddindexA.val() == null) {
			    showError("error", "Informe o indexador.", "Alerta - Ayllos", "cCddindexA.habilitaCampo(); cCddindexA.focus();");
                return false;
            }
			
            if (e.keyCode == 9) {
				btnSalvar.focus();
                return false;
            } else if (e.keyCode == 13) {
				limpaCamposAlteracao();
                cCddindexA.desabilitaCampo();
                cIdperiodA.focus();
                return false;
            }
        }
    });

    $('#idperiodA', '#frmCab').unbind('keypress').bind('keypress', function(e) {

        if (e.keyCode == 9 || e.keyCode == 13) {
            if (cIdperiodA.val() == 0 || cIdperiodA.val() == '') {
                showError("error", "Informe a Periodicidade indexador.", "Alerta - Ayllos", "cIdperiodA.focus();");
                return false;
            } else {
                cIdexpresA.focus();
                return false;
            }
        }
    });

    $('#idexpresA', '#frmCab').unbind('keypress').bind('keypress', function(e) {

        if (e.keyCode == 9 || e.keyCode == 13) {
            if (cIdexpresA.val() == 0 || cIdexpresA.val() == '') {
                showError("error", "Informe a Taxa Expressa.", "Alerta - Ayllos", "cIdexpresA.focus();");
                return false;
            } else {
                cIdcadastA.focus();
                return false;
            }
        }
    });

    $('#idcadastA', '#frmCab').unbind('keypress').bind('keypress', function(e) {

        if (e.keyCode == 9 || e.keyCode == 13) {
            if (cIdcadastA.val() == 0 || cIdcadastA.val() == '') {
                showError("error", "Informe a Forma de Cadastro.", "Alerta - Ayllos", "cIdcadastA.focus();");
                return false;
            } else {
                msgConfirmacao();
                return false;
            }
        }
    });

    /* Fim Opcao de Alteracao */

    $('#btnOK', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            escolheOpcao();
            return false;
        }
    });

    $('#vlrdtaxa', '#frmCab').unbind('keypress').bind('keypress', function(e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            msgConfirmacao();
            return false;
        }
    });


}

function carregaCombo(cddOpcao) {

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/indice/carrega_combo.php",
        data: {
            cddopcao: cddOpcao,
            redirect: "script_ajax"
        },
        success: function(response) {
            eval(response);
        }
    });
}

function validaData() {

    var cddindex = cCddindexT.val();
    var dtperiod = cDtperiod.val();
    var tipodata = dtperiod.length;

    if (tipodata == 4 && (parseInt(dtperiod.substr(0, 4)) < 1900 || parseInt(dtperiod.substr(0, 4)) >= 3000)) {
        showError("error", "Informe uma data valida.", "Alerta - Ayllos", "cDtperiod.attr('disabled',false);cDtperiod.focus();");
        return false;
    } else if (tipodata == 7 && ((parseInt(dtperiod.substr(0, 2)) < 1 || parseInt(dtperiod.substr(0, 2)) > 12) ||
            (parseInt(dtperiod.substr(3, 4)) < 1900 || parseInt(dtperiod.substr(3, 4)) > 3000))) {
        showError("error", "Informe uma data valida.", "Alerta - Ayllos", "cDtperiod.attr('disabled',false);cDtperiod.focus();");
        return false;
    } else if (tipodata == 10 && ((parseInt(dtperiod.substr(0, 2)) < 1 || parseInt(dtperiod.substr(0, 2)) > 31) ||
            (parseInt(dtperiod.substr(3, 2)) < 1 || parseInt(dtperiod.substr(3, 2)) > 12) ||
            (parseInt(dtperiod.substr(6, 4)) < 1900 || parseInt(dtperiod.substr(6, 4)) > 3000))) {
        showError("error", "Informe uma data valida.", "Alerta - Ayllos", "cDtperiod.attr('disabled',false);cDtperiod.focus();");
        return false;
    } else if (tipodata == 0) {
        showError("error", "Informe uma data valida.", "Alerta - Ayllos", "cDtperiod.attr('disabled',false);cDtperiod.focus();");
        return false;
    } else {

        // Mostra mensagem de aguardo
        showMsgAguardo("Aguarde, validando dados...");

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/indice/manter_data.php",
            data: {
                cddopcao: cCddopcao.val(),
                cddindex: cddindex,
                dtperiod: dtperiod,
                redirect: "script_ajax"
            },
            success: function(response) {
                hideMsgAguardo();
                eval(response);
            }
        });
    }

}

function manterTaxa(cddopcao) {

    var cddindex = cCddindexT.val();
    var dtperiod = cDtperiod.val();
    var vlrdtaxa = cVlrdtaxa.val();

    if (cddindex == 0 || cddindex == '') {
        showError("error", "Indexador inv&aacute;lido.", "Alerta - Ayllos", "cCddindex.focus();");
    } else if (dtperiod == 0 || dtperiod == '') {
        showError("error", "Per&iacute;odo inv&aacute;lido.", "Alerta - Ayllos", "cDtperiod.focus();");
    } else if (vlrdtaxa == 0 || vlrdtaxa == '') {
        showError("error", "Per&iacute;odo inv&aacute;lido.", "Alerta - Ayllos", "cDtperiod.focus();");
    }

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, validando dados...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/indice/manter_taxa.php",
        data: {
            cddopcao: cddopcao,
            cddindex: cddindex,
            dtperiod: dtperiod,
            vlrdtaxa: vlrdtaxa,
            redirect: "script_ajax"
        },
        success: function(response) {
            hideMsgAguardo();
            eval(response);
        }
    });
}

// Formata Browse da Tela
function formataTabelaIndice() {

    // Tabela
    $('#tabIndice').css({'display': 'block'});
    $('#divConsulta').css({'display': 'block'});

    var divRegistro = $('div.divRegistros', '#tabIndice');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    $('#tabIndice').css({'margin-top': '5px'});
    divRegistro.css({'height': '200px', 'width': '700px', 'padding-bottom': '2px'});

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '130px';
    arrayLargura[1] = '130px';
    arrayLargura[2] = '140px';
    arrayLargura[3] = '120px';
    arrayLargura[4] = '120px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'right';
    arrayAlinha[2] = 'right';
    arrayAlinha[3] = 'right';
    arrayAlinha[4] = 'right';

    var metodoTabela = 'verDetalhe(this)';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
    hideMsgAguardo();

    return false;
}

function buscaIndice(nriniseq, nrregist) {

    glb_nriniseq = nriniseq;
    glb_nrregist = nrregist;

    var idperiod = cIdperiodI.val();
    var idexpres = cIdexpresI.val();
    var idcadast = $('input[name=idcadastI]:checked', '#' + frmCab).val();
    var dtiniper = 0;
    var dtfimper = 0;

    if (cCddopcao.val() == 'A') {
        cddindex = cCddindexA.val();
    } else if (cCddopcao.val() == 'C') {
        cddindex = cCddindexC.val();
    } else if (cCddopcao.val() == 'T') {
        cddindex = cCddindexT.val();
    } else {
        cddindex = 0;
    }

    if ($("#dtPeriodAno", '#' + frmCab).is(':visible')) {
        dtiniper = cDtiniperAno.val();
        dtfimper = cDtfimperAno.val();
    } else if ($("#dtPeriodMes", '#' + frmCab).is(':visible')) {
        dtiniper = cDtiniperMes.val();
        dtfimper = cDtfimperMes.val();
    }

    showMsgAguardo("Aguarde, buscando registros de taxas...");

    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/indice/manter_rotina.php",
        data: {
            cddindex: cddindex,
            idperiod: idperiod,
            idexpres: idexpres,
            idcadast: idcadast,
            cddopcao: cCddopcao.val(),
            nmdindex: cNmdindex.val(),
            dtperiod: cDtperiod.val(),
            dtiniper: dtiniper,
            dtfimper: dtfimper,
            vlrdtaxa: cVlrdtaxa.val(),
            nriniseq: glb_nriniseq,
            nrregist: glb_nrregist,
			flgalter: flgAltera,
            redirect: "script_ajax"
        },
        success: function(response) {
            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1) {
                $('#divConsulta').html(response);
                formataTabelaIndice();
                $("#btVoltar", "#btnConsulta").attr("onclick", "fechaConsulta()");
            } else {
                eval(response);
            }
        }
    });

    return false;
}

function limpaTela() {

    var frmVisible = $("#frmTaxas").is(':visible');

	flgAltera = 0;
	
    $("#divIndice div").each(function(i) {

        if (cCddopcao.val() == 'C' && frmVisible == true) {
            escolheOpcao();
        } else {
            $(this).hide();
        }
    });
    btnOK.show();
}

function geraImpressao(arquivo) {

    $('#nmarquiv', '#frmImprimir').val(arquivo);

    var action = UrlSite + 'telas/indice/imprimir_dados.php';

    carregaImpressaoAyllos("frmImprimir", action);

}

function fechaConsulta() {
    cCddopcao.val('C');
    escolheOpcao();
}

function consultaTipoData(cddindex) {
    showMsgAguardo("Aguarde, consultando tipo de data...");

    // Executa script de bloqueio através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/indice/consulta_data.php",
        data: {
            cddindex: cddindex,
			cddopcao: cCddopcao.val(),
            redirect: "script_ajax"
        },
        success: function(response) {
            hideMsgAguardo();

            if (response == '1') {
                divMes.hide();
                divAno.show();
            } else if (response == '0') {
                divAno.hide();
                divMes.show();
            } else {
                eval(response);
            }
			cCddindexC.desabilitaCampo();
        }
    });

    return false;
}
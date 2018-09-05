/*!
 * FONTE        : lrotat.js                                 Última alteração: 24/08/2018
 * CRIAÇÃO      : Otto - RKAM
 * DATA CRIAÇÃO : 06/07/2016
 * OBJETIVO     : Biblioteca de funções da tela LROTAT
 * --------------
 * ALTERAÇÕES   : 12/07/2016 - Ajustes para finzaliZação da conversáo 
 *                               (Andrei - RKAM)
 *
 *                05/12/2016 - P341-Automatização BACENJUD - Alterar a validação do deparetamento
 *                             para tratar pelo código do mesmo (Renato Darosci)
 *
 *				  10/10/2017 - Inclusao dos campos Modelo e % Mínimo Garantia. (Lombardi - PRJ404)
 *
 *                24/08/2018 - inc0022526 ativação do campo qtvcapce Ailos na opção Alterar (Carlos)
 * --------------
 */


$(document).ready(function() {

	estadoInicial();
	
});

// seletores

function estadoInicial() {

    $('#divTela').fadeTo(0, 0.1);
	removeOpacidade('divTela');

	formataCabecalho();

	removeOpacidade('divTela');
	highlightObjFocus($('#frmCab'));
	$('#frmCab').css({ 'display': 'block' });
	$('#divTela').css({ 'width': '700px', 'padding-bottom': '2px' });
	$('#divTabela').html('').css('display','none');

	$('#divBotoesFiltro').css('display', 'none');
	$('#frmFiltro').css('display', 'none');

	$("#cddopcao", "#frmCab").focus();

}


function formataCabecalho() {

    // rotulo
    $('label[for="cddopcao"]', "#frmCab").addClass("rotulo").css({ "width": "45px" });

    // campo
    $("#cddopcao", "#frmCab").css("width", "530px").habilitaCampo();

    $('input[type="text"],select', '#frmCab').limpaFormulario().removeClass('campoErro');

    //Define ação para ENTER e TAB no campo opção
    $("#cddopcao", "#frmCab").unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            formataFormularioFiltro();

            return false;

        }
    });

    //Define ação para CLICK no botÃ£o de OK
    $("#btnOK", "#frmCab").unbind('click').bind('click', function () {

        // Se esta desabilitado o campo 
        if ($("#cddopcao", "#frmCab").prop("disabled") == true) {
            return false;
}

        formataFormularioFiltro();

        $(this).unbind('click');

        return false;
    });

    layoutPadrao();

    return false;
}


function formataFormularioFiltro() {

    // Desabilitar a opção
    $("#cddopcao", "#frmCab").desabilitaCampo();

    //Limpa formulario
    $('input[type="text"]', '#frmFiltro').limpaFormulario().removeClass('campoErro');

    // rotulo
    $('label[for="cddlinha"]', "#frmFiltro").addClass("rotulo").css({ "width": "80px" });

    // campo
    $("#cddlinha", "#frmFiltro").css({ 'width': '100px', 'text-align': 'right' }).addClass('alphanum').attr('maxlength', '3').habilitaCampo();
    
    $('#cddlinha', '#frmFiltro').unbind('keypress').bind("keypress", function (e) {

        $(this).removeClass('campoErro');

        if (e.keyCode == 9 || e.keyCode == 13) {
            
            $('#btProsseguir', '#divBotoesFiltro').click();
            return false;
        }
    });

    $('#frmFiltro').css({ 'display': 'block' });
    $('#divBotoesFiltro').css({ 'display': 'block' });
    $('#btProsseguir', '#divBotoesFiltro').css({ 'display': 'inline' });
    $('#btVoltar', '#divBotoesFiltro').css({ 'display': 'inline' });
    highlightObjFocus($('#frmLrotat'));

    layoutPadrao();

    $('#cddlinha', '#frmFiltro').focus();

    return false;

}

function formataFormularioLrotat(){

    var cddopcao = $('#cddopcao', '#frmCab').val();

    // rotulo
    $('label[for="dsdlinha"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[for="tpdlinha"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[for="dssitlcr"]', "#frmLrotat").addClass("rotulo-linha").css({ "width": "60px" });
    $('label[for="qtvezcap"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[for="vllimmax"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[for="qtdiavig"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px", 'padding-right': '114px' });
    $('label[for="txjurfix"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px", 'padding-right': '114px' });
    $('label[for="txjurvar"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px", 'padding-right': '114px' });
    $('label[for="txmensal"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px", 'padding-right': '114px' });
    $('label[for="tpctrato"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[for="permingr"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[for="dsencfin1"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[for="dsencfin2"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[for="dsencfin2"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[id="Operacional"]', "#frmLrotat").addClass("rotulo").css({ "width": "310px" });
    $('label[id="Ailos"]', "#frmLrotat").addClass("rotulo-linha").css({ "width": "90px" });
    $('label[for="origrecu"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[for="cdmodali"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });
    $('label[for="cdsubmod"]', "#frmLrotat").addClass("rotulo").css({ "width": "215px" });

    // campo
    $("#dsdlinha", "#frmLrotat").css({ 'width': '330px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '40').desabilitaCampo();
    $('#tpdlinha', '#frmLrotat').css({ 'width': '145px', 'text-align': 'left' }).desabilitaCampo();
    $('#dssitlcr', '#frmLrotat').css("width", "120px").desabilitaCampo();
    $('#qtvezcap', '#frmLrotat').css({ 'width': '110px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $('#qtvcapce', '#frmLrotat').css({ 'width': '110px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $('#vllimmax', '#frmLrotat').css({ 'width': '110px', 'text-align': 'left' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $('#vllmaxce', '#frmLrotat').css({ 'width': '110px', 'text-align': 'left' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '32').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $('#qtdiavig', '#frmLrotat').css({ 'width': '110px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '4');
    $('#txjurfix', '#frmLrotat').css({ 'width': '110px', 'text-align': 'right' }).desabilitaCampo().addClass('porcento_6').attr('maxlength', '10').css({ 'text-align': 'right' });
    $('#txjurvar', '#frmLrotat').css({ 'width': '110px', 'text-align': 'left' }).desabilitaCampo().addClass('porcento_6').attr('maxlength', '10').css({ 'text-align': 'right' });
    $('#txmensal', '#frmLrotat').css({ 'width': '110px', 'text-align': 'left' }).desabilitaCampo().addClass('porcento_6').attr('maxlength', '10').css({ 'text-align': 'right' });
    $('#tpctrato', '#frmLrotat').css({ 'width': '110px', 'text-align': 'left' }).desabilitaCampo();
    $('#permingr', '#frmLrotat').css({ 'width': '110px', 'text-align': 'right' }).desabilitaCampo().setMask('DECIMAL','zz9,99','.','');
    $('#dsencfin1', '#frmLrotat').css({ 'width': '380px', 'text-align': 'left' }).desabilitaCampo().addClass('alphanum').attr('maxlength', '50');
    $('#dsencfin2', '#frmLrotat').css({ 'width': '380px', 'text-align': 'left' }).desabilitaCampo().addClass('alphanum').attr('maxlength', '50');
    $('#dsencfin3', '#frmLrotat').css({ 'width': '380px', 'text-align': 'left' }).desabilitaCampo().addClass('alphanum').attr('maxlength', '50');
    $('#origrecu', '#frmLrotat').css({ 'width': '380px', 'text-align': 'left' }).desabilitaCampo().addClass('alphanum').attr('maxlength', '40');
    $('#cdmodali', '#frmLrotat').css({ 'width': '60px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '5').setMask("INTEGER", "zzzzz", "", "");
    $('#dsmodali', '#frmLrotat').css({ 'width': '295px', 'text-align': 'left' }).desabilitaCampo().addClass('alphanum').attr('maxlength', '50');
    $('#cdsubmod', '#frmLrotat').css({ 'width': '60px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '5').setMask("INTEGER", "zzzzz", "", "");
    $('#dssubmod', '#frmLrotat').css({ 'width': '295px', 'text-align': 'left' }).desabilitaCampo().addClass('alphanum').attr('maxlength', '50');

    highlightObjFocus($('#frmLrotat'));

    $('#frmLrotat').css('display', 'block');
    $('#divTabela').css('display', 'block');
    $('#divBotoesFiltro').css('display', 'none');
    $('#divBotoesFiltroLrotat').css('display', 'block');

	switch (cddopcao) {
	       
	    case 'C':

	        layoutPadrao();
	        removeProsseguir('btnVoltar(2); return false;');
	        $("#btVoltar", "#divBotoesFiltro").focus();

	        break;

	    case 'B':
	       
            trocaBotao('showConfirmacao(\'Deseja prosseguir com a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'bloqlibLinhaDesconto();\',\'\',\'sim.gif\',\'nao.gif\')', 'btnVoltar(2)');
	        layoutPadrao();
	        
	        break;

	    case 'L':
	        
	        trocaBotao('showConfirmacao(\'Deseja prosseguir com a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'bloqlibLinhaDesconto();\',\'\',\'sim.gif\',\'nao.gif\')', 'btnVoltar(2)');
	        layoutPadrao();

	        break;

	    case 'A':

	        $('input,select', '#frmLrotat').habilitaCampo();

	        $("#tpdlinha", "#frmLrotat").desabilitaCampo();
	        $("#dssitlcr", "#frmLrotat").desabilitaCampo();
	        $("#txmensal", "#frmLrotat").desabilitaCampo();
	        $("#tpctrato", "#frmLrotat").desabilitaCampo();
	        $("#permingr", "#frmLrotat").desabilitaCampo();
	        $("#dsmodali", "#frmLrotat").desabilitaCampo();
	        $("#dssubmod", "#frmLrotat").desabilitaCampo();

	        $("#dsdlinha", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#tpdlinha", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#qtvezcap", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#vllimmax", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#vllmaxce", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#qtdiavig", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#txjurfix", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#txjurvar", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

			$("#tpctrato", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

				if (divError.css('display') == 'block') { return false; }

				$('input,select').removeClass('campoErro');

				// Se é a tecla ENTER, TAB, F1
				if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
					/*
					if ($(this).val() == 4) {
						$("#permingr", "#frmConsulta").focus();
					} else {
						$("#dsencfin1", "#frmConsulta").focus();
					}
					*/
	                $(this).nextAll('.campo:first').focus();
					return false;
				}
	        });

	        $("#permingr", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#dsencfin1", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#dsencfin2", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#dsencfin3", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $("#origrecu", "#frmLrotat").focus();

	                return false;

	            }

	        });

	        $("#origrecu", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        // Se pressionar cdmodali
	        $('#cdmodali', '#frmLrotat').unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                bo = 'tela_lrotat';
	                procedure = 'BUSCAMOD';
	                titulo = 'Modalidades';
	                qtReg = '30';

	                $(this).removeClass('campoErro');
	                buscaDescricao(bo, procedure, titulo, 'cdmodali', 'dsmodali', $('#cdmodali', '#frmLrotat').val(), 'dsmodali', 'nriniseq|1;nrregist|30', 'frmLrotat');

	                $('#cdmodali', '#frmLrotat').focus();

	                return false;

	            }

	        });

	        // Se pressionar cdsubmod
	        $('#cdsubmod', '#frmLrotat').unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                bo = 'tela_lrotat';
	                procedure = 'BUSCASUBMOD';
	                titulo = 'Submodalidades';
	                qtReg = '30';
	                filtrosDesc = 'cdmodali|' + $('#cdmodali', '#frmLrotat').val() + ';nriniseq|1;nrregist|30';

	                $(this).removeClass('campoErro');
	                buscaDescricao(bo, procedure, titulo, 'cdsubmod', 'dssubmod', $('#cdsubmod', '#frmLrotat').val(), 'dssubmod', filtrosDesc, 'frmLrotat');

	                $(this).focus();

	                return false;

	            }

	        });

	        
	        /* Descricao so pode ser alterada pela Central */
	        if (cddepart == 8  ||  /* COORD.ADM/FINANCEIRO */
                cddepart == 14 ||  /* PRODUTOS */
                cddepart == 20 ) { /* TI */

	            $("#dsdlinha", "#frmLrotat").habilitaCampo();
	            $("#origrecu", "#frmLrotat").habilitaCampo();
	            $("#cdmodali", "#frmLrotat").habilitaCampo();
	            $("#cdsubmod", "#frmLrotat").habilitaCampo();

	        } else {
	            $("#dsdlinha", "#frmLrotat").desabilitaCampo();
	            $("#origrecu", "#frmLrotat").desabilitaCampo();
	            $("#cdmodali", "#frmLrotat").desabilitaCampo();
	            $("#cdsubmod", "#frmLrotat").desabilitaCampo();
	        }

	        /* Descricao so pode ser alterada pela Central */
	        if (cddepart != 8   &&  /* COORD.ADM/FINANCEIRO */
                cddepart != 14  &&  /* PRODUTOS */
                cddepart != 20) {   /* TI */

	            $("#qtvezcap", "#frmLrotat").habilitaCampo();
	            $("#vllimmax", "#frmLrotat").habilitaCampo();

	            $("#vllmaxce", "#frmLrotat").desabilitaCampo();
	            $("#qtdiavig", "#frmLrotat").desabilitaCampo();
	            $("#txjurfix", "#frmLrotat").desabilitaCampo();
	            $("#txjurvar", "#frmLrotat").desabilitaCampo();
	            $("#dsencfin1", "#frmLrotat").desabilitaCampo();
	            $("#dsencfin2", "#frmLrotat").desabilitaCampo();
	            $("#dsencfin3", "#frmLrotat").desabilitaCampo();

	            $("#qtvezcap", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	                if (divError.css('display') == 'block') { return false; }

	                $('input,select').removeClass('campoErro');

	                // Se é a tecla ENTER, TAB, F1
	                if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                    $(this).nextAll('.campo:first').focus();

	                    return false;

	                }

	            });

	            $("#vllimmax", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	                if (divError.css('display') == 'block') { return false; }

	                $('input,select').removeClass('campoErro');

	                // Se é a tecla ENTER, TAB, F1
	                if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                    $("#btSalvar", "#divBotoesFiltroLrotat").click();

	                    return false;

	                }

	            });


	        } else {

	            $("#qtvezcap", "#frmLrotat").habilitaCampo();
	            $("#vllimmax", "#frmLrotat").habilitaCampo();
	            $("#vllmaxce", "#frmLrotat").habilitaCampo();
	            $("#qtdiavig", "#frmLrotat").habilitaCampo();
	            $("#txjurfix", "#frmLrotat").habilitaCampo();
	            $("#txjurvar", "#frmLrotat").habilitaCampo();
				($("#tpctrato", "#frmLrotat").val() == 4) ? $('#permingr', '#frmLrotat').habilitaCampo() : $('#permingr', '#frmLrotat').desabilitaCampo();
	            $("#dsencfin1", "#frmLrotat").habilitaCampo();
	            $("#dsencfin2", "#frmLrotat").habilitaCampo();
	            $("#dsencfin3", "#frmLrotat").habilitaCampo();

	        }

	        trocaBotao('showConfirmacao(\'Deseja prosseguir com a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'calculaTaxa();\',\'\',\'sim.gif\',\'nao.gif\')', 'btnVoltar(2)');

	        layoutPadrao();

            $('.campo','#frmLrotat').first().focus();

	        break;

	    case 'I':	        
	        
	        $("#dssitlcr", "#frmLrotat").val('Liberada').desabilitaCampo();	       

	        $("#dsdlinha", "#frmLrotat").habilitaCampo();
	        $("#tpdlinha", "#frmLrotat").habilitaCampo();
	        $("#qtvezcap", "#frmLrotat").habilitaCampo();
	        $("#vllimmax", "#frmLrotat").habilitaCampo();
	        $("#vllmaxce", "#frmLrotat").habilitaCampo();
	        $("#qtdiavig", "#frmLrotat").habilitaCampo();
	        $("#txjurfix", "#frmLrotat").habilitaCampo();
	        $("#txjurvar", "#frmLrotat").habilitaCampo();
			$("#tpctrato", "#frmLrotat").habilitaCampo();
			($("#tpctrato", "#frmLrotat").val() == 4) ? $('#permingr', '#frmLrotat').habilitaCampo() : $('#permingr', '#frmLrotat').desabilitaCampo();
	        $("#dsencfin1", "#frmLrotat").habilitaCampo();
	        $("#dsencfin2", "#frmLrotat").habilitaCampo();
	        $("#dsencfin3", "#frmLrotat").habilitaCampo();

	        $("#origrecu", "#frmLrotat").habilitaCampo();
	        $("#cdmodali", "#frmLrotat").habilitaCampo();
	        $("#cdsubmod", "#frmLrotat").habilitaCampo();

	        $("#dsdlinha", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#tpdlinha", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#qtvezcap", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#vllimmax", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#vllmaxce", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#qtdiavig", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#txjurfix", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#txjurvar", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#tpctrato", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

			//Define ação para o campo tpctrato
			$('#tpctrato', '#frmLrotat').unbind('change').bind('change', function () {

				if ($(this).val() == 4) {
					$("#permingr", "#frmLrotat").val('100,00').habilitaCampo();
				} else {
					$("#permingr", "#frmLrotat").val('0,00').desabilitaCampo();
	            }
			});

			$("#tpctrato", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

				if (divError.css('display') == 'block') { return false; }

				$('input,select').removeClass('campoErro');
				
				// Se é a tecla ENTER, TAB, F1
				if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {
					/*
					if ($(this).val() == 4) {
						$("#permingr", "#frmConsulta").focus();
					} else {
						$("#dsencfin1", "#frmConsulta").focus();
					}
					*/
	                $(this).nextAll('.campo:first').focus();
					return false;
				}
	        });

	        $("#permingr", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#dsencfin1", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#dsencfin2", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        $("#dsencfin3", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $("#origrecu", "#frmLrotat").focus();

	                return false;

	            }

	        });

	        $("#origrecu", "#frmLrotat").unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                $(this).nextAll('.campo:first').focus();

	                return false;

	            }

	        });

	        // Se pressionar cdmodali
	        $('#cdmodali', '#frmLrotat').unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                bo = 'tela_lrotat';
	                procedure = 'BUSCAMOD';
	                titulo = 'Modalidades';
	                qtReg = '30';

	                $(this).removeClass('campoErro');
	                buscaDescricao(bo, procedure, titulo, 'cdmodali', 'dsmodali', $('#cdmodali', '#frmLrotat').val(), 'dsmodali', 'nriniseq|1;nrregist|30', 'frmLrotat');

	                $('#cdmodali', '#frmLrotat').focus();

	                return false;

	            }

	        });

	        // Se pressionar cdsubmod
	        $('#cdsubmod', '#frmLrotat').unbind('keypress').bind('keypress', function (e) {

	            if (divError.css('display') == 'block') { return false; }

	            $('input,select').removeClass('campoErro');

	            // Se é a tecla ENTER, TAB, F1
	            if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

	                bo = 'tela_lrotat';
	                procedure = 'BUSCASUBMOD';
	                titulo = 'Submodalidades';
	                qtReg = '30';

	                filtrosDesc = 'cdmodali|' + $('#cdmodali', '#frmLrotat').val() + ';nriniseq|1;nrregist|30';

	                $(this).removeClass('campoErro');
	                buscaDescricao(bo, procedure, titulo, 'cdsubmod', 'dssubmod', $('#cdsubmod', '#frmLrotat').val(), 'dssubmod', filtrosDesc, 'frmLrotat');

	                $(this).focus();

	                return false;

	            }

	        });

	        trocaBotao('showConfirmacao(\'Deseja prosseguir com a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'calculaTaxa();\',\'\',\'sim.gif\',\'nao.gif\')', 'btnVoltar(2)');
	        layoutPadrao();
	        $('#dsdlinha', '#frmLrotat').focus();
	        break;

	    case 'E':
	        
	        trocaBotao('showConfirmacao(\'Deseja prosseguir com a opera&ccedil;&atilde;o?\',\'Confirma&ccedil;&atilde;o - Ayllos\',\'excluiLinhaDesconto();\',\'\',\'sim.gif\',\'nao.gif\')', 'btnVoltar(2)');
	        layoutPadrao();
	        $("#btVoltar", "#divBotoesFiltro").focus();

	        break;

	}

	return false;

}


function btnVoltar(op) {


    switch (op) {

        case 1:
            estadoInicial();
        break;

        case 2:
            $('#divTabela').css('display','none');
            formataFormularioFiltro();
            
	        break;

    }

}

function btnProsseguir() {

    var cddopcao = $('#cddopcao','#frmCab').val();   

    var cddlinha = $('#cddlinha', '#frmFiltro').val();
   
    switch (cddopcao) {

        case 'C':
            buscaLinhaRotativo();

        break;

        case 'B':
            showConfirmacao('Deseja prosseguir com a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'bloqlibLinhaDesconto();', '$("#nrdconta","#frmFiltro").focus();', 'sim.gif', 'nao.gif');

        break;

        case 'L':
            showConfirmacao('Deseja prosseguir com a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'bloqlibLinhaDesconto();', '$("#nrdconta","#frmFiltro").focus();', 'sim.gif', 'nao.gif');

        break;        

        case 'A':
            buscaLinhaRotativo();
            
        break;

        case 'I':
            //alteraLinhaDesconto();
        break;

        case 'E':
            showConfirmacao('Deseja prosseguir com a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluiLinhaDesconto();', '$("#nrdconta","#frmFiltro").focus();', 'sim.gif', 'nao.gif');

        break;

    }

    return false;

}

/*
 * Busca Linha de crédito rotativo
 */
function buscaLinhaRotativo(cddlinha) {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var cddlinha = normalizaNumero($('#cddlinha', '#frmFiltro').val());

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, buscando linha de cr&eacute;dito rotativo ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lrotat/busca_lrotat.php",
        data: {
            cddopcao: cddopcao,
            cddlinha: cddlinha,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "formataFormularioLrotat();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTabela').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "formataFormularioLrotat();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "formataFormularioLrotat();");
                }
            }
        }

    });
    return false;
}

function bloqlibLinhaDesconto() {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var cddlinha = $('#cddlinha', '#frmFiltro').val();

    $('input,select', '#frmFiltro').removeClass('campoErro');

    showMsgAguardo("Aguarde, bloqueando linha de cr&eacute;dito rotativo ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lrotat/bloqlib_lrotat.php",
        data: {
            cddopcao: cddopcao,
            cddlinha: cddlinha,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesFiltroLrotat').focus();");
        },
        success: function (response) {
            $('#frmLrotat').show();

            hideMsgAguardo();
            
            try {

                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesFiltroLrotat').focus();");
            }
            
        }

    });
    return false;
}

function manterLrotat() {

    //Desabilita todos os campos do form
    $('input,select', '#frmFiltro').desabilitaCampo();

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var cddlinha = $('#cddlinha', '#frmFiltro').val();

    var dsdlinha = $('#dsdlinha', '#frmLrotat').val();
    var tpdlinha = $('#tpdlinha', '#frmLrotat').val();
    var qtvezcap = isNaN(parseFloat($('#qtvezcap', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#qtvezcap', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));
    var qtvcapce = isNaN(parseFloat($('#qtvcapce', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#qtvcapce', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));
    var vllimmax = isNaN(parseFloat($('#vllimmax', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vllimmax', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));
    var vllmaxce = isNaN(parseFloat($('#vllmaxce', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vllmaxce', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));
    var vllmaxce = isNaN(parseFloat($('#vllmaxce', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vllmaxce', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));
    var qtdiavig = $('#qtdiavig', '#frmLrotat').val();
    var txjurfix = isNaN(parseFloat($('#txjurfix', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txjurfix', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));
    var txjurvar = isNaN(parseFloat($('#txjurvar', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txjurvar', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));
    var txmensal = isNaN(parseFloat($('#txmensal', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txmensal', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));
    var tpctrato = $('#tpctrato', '#frmLrotat').val();
    var permingr = isNaN(parseFloat($('#permingr', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#permingr', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));
    var dsencfin1  = $('#dsencfin1', '#frmLrotat').val();
    var dsencfin2  = $('#dsencfin2', '#frmLrotat').val();
    var dsencfin3 = $('#dsencfin3', '#frmLrotat').val();
    var origrecu = $('#origrecu', '#frmLrotat').val();
    var cdmodali = $('#cdmodali', '#frmLrotat').val();
    var cdsubmod = $('#cdsubmod', '#frmLrotat').val();

    $('input,select', '#frmLrotat').removeClass('campoErro');

    showMsgAguardo("Aguarde, realizando operação ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lrotat/manter_lrotat.php",
        data: {
            cddopcao: cddopcao,
            cddlinha: cddlinha,
            tpdlinha: tpdlinha,
            dsdlinha: dsdlinha,
            qtvezcap: qtvezcap,
            qtvcapce: qtvcapce,
            vllimmax: vllimmax,
            vllmaxce: vllmaxce,
            txmensal: txmensal,
			tpctrato: tpctrato,
			permingr: permingr,
            qtdiavig: qtdiavig, 
            txjurfix: txjurfix,
            txjurvar: txjurvar,
            dsencfin1: dsencfin1,
            dsencfin2: dsencfin2,
            dsencfin3: dsencfin3,
            origrecu: origrecu,
            cdmodali: cdmodali,
            cdsubmod: cdsubmod,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
        },
        success: function (response) {
            
            hideMsgAguardo();
            
            try {

                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#nrdconta','#frmFiltro').focus();");
            }
            
        }

    });

    return false;

}

function trocaBotao( funcaoSalvar,funcaoVoltar ) {
    
    $('#divBotoesFiltroLrotat', '#divTela').html('');
    $('#divBotoesFiltroLrotat', '#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="' + funcaoVoltar + '; return false;" >Voltar</a>&nbsp;');
    $('#divBotoesFiltroLrotat', '#divTela').append('<a href="#" class="botao" id="btSalvar" onClick="' + funcaoSalvar + '; return false;">Prosseguir</a>');
    
    return false;
}

function removeProsseguir(funcaoVoltar) {
    $('#divBotoesFiltroLrotat', '#divTela').html('');
    $('#divBotoesFiltroLrotat', '#divTela').append('<a href="#" class="botao" id="btVoltar" onClick="' + funcaoVoltar + '; return false;" >Voltar</a>&nbsp;');
    
    return false;
}

function excluiLinhaDesconto() {
	
    //Desabilita todos os campos do form
    $('input,select', '#frmLrotat').desabilitaCampo();

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var cddlinha = $('#cddlinha', '#frmFiltro').val();

    $('input,select', '#frmLrotat').removeClass('campoErro');

    showMsgAguardo("Aguarde, excluindo linha de cr&eacute;dito rotativo ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lrotat/excluir_lrotat.php",
        data: {
            cddopcao: cddopcao,
            cddlinha: cddlinha,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesFiltroLrotat').focus();");
        },
        success: function (response) {            

            hideMsgAguardo();
            
            try {

                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesFiltroLrotat').focus();");
            
            }
        }

    });

    return false;
}


function calculaTaxa() {

    //Desabilita todos os campos do form
    $('input,select', '#frmLrotat').desabilitaCampo();

    var cddopcao = $('#cddopcao', '#frmCab').val();
    var txjurfix = isNaN(parseFloat($('#txjurfix', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txjurfix', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));
    var txjurvar = isNaN(parseFloat($('#txjurvar', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#txjurvar', '#frmLrotat').val().replace(/\./g, "").replace(/\,/g, "."));

    $('input,select', '#frmLrotat').removeClass('campoErro');

    showMsgAguardo("Aguarde, calculando taxa mensal ...");

    //Requisição para processar a opção que foi selecionada
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/lrotat/calcula_taxa.php",
        data: {
            cddopcao: cddopcao,
            txjurvar: txjurvar,
            txjurfix: txjurfix,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesFiltroLrotat').focus();");
        },
        success: function (response) {

            hideMsgAguardo();

            try {

                eval(response);
            } catch (error) {

                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesFiltroLrotat').focus();");

            }
        }

    });

    return false;
}


function controlaPesquisa(valor) {

    switch (valor) {

        case 1:
            controlaPesquisaLinha();
            break;

        case 2:
            controlaPesquisaModalidade();
            break;

        case 3:
            controlaPesquisaSubModalidade();
            break;


    }

    }

function controlaPesquisaLinha() {

    // Se esta desabilitado o campo 
    if ($("#cddlinha", "#frmFiltro").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input', '#frmFiltro').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    var nrconven = normalizaNumero($('#cddlinha', '#frmFiltro').val());

    //Definição dos filtros
    var filtros = "Linhas;cddlinha;120px;S;;;";

    //Campos que serão exibidos na tela
    var colunas = 'Código;cddlinha;10%;right|Descrição;dsdlinha;50%;left|Tipo;dsdtplin;20%;left;|Taxa;dsdtxfix;20%;right';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "BUSCALINHAS", "Linhas de Cr&eacute;dito Rotativo", "30", filtros, colunas, '', '$(\'#cddlinha\',\'#frmFiltro\').focus();', 'frmFiltro');

    $("#divCabecalhoPesquisa > table").css("width", "600px");
    $("#divResultadoPesquisa > table").css("width", "600px");
    $("#divCabecalhoPesquisa").css("width", "600px");
    $("#divResultadoPesquisa").css("width", "600px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}


function controlaPesquisaModalidade() {

    // Se esta desabilitado o campo 
    if ($("#cdmodali", "#frmLrotat").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmLrotat').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = "Linhas;cdmodali;20%;S;0;N;|Descrição;dsmodali;50%;S;;N;";

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdmodali;20%;center|Descrição;dsmodali;50%;left';
    
    //Exibir a pesquisa
    mostraPesquisa("tela_lrotat", "BUSCAMOD", "Modalidades", "30", filtros, colunas, '', '$(\'#cdmodali\',\'#frmLrotat\').val();', 'frmLrotat');

    $("#divCabecalhoPesquisa > table").css("width", "600px");
    $("#divResultadoPesquisa > table").css("width", "600px");
    $("#divCabecalhoPesquisa").css("width", "600px");
    $("#divResultadoPesquisa").css("width", "600px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}


function controlaPesquisaSubModalidade() {

    // Se esta desabilitado o campo 
    if ($("#cdsubmod", "#frmLrotat").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmLrotat').removeClass('campoErro');

    // Variável local para guardar o elemento anterior
    var campoAnterior = '';
    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Submodalidade;cdsubmod;20%;S;;;codigo;|Descrição;dssubmod;50%;S;;N;|Cód. Modalidade;cdmodali;20%;N;' + $('#cdmodali', '#frmLrotat').val() + ';S;codigo;';
    
    //Campos que serão exibidos na tela
    var colunas = 'Código;cdsubmod;20%;center|Descrição;dssubmod;50%;left';

    //Exibir a pesquisa
    mostraPesquisa("tela_lrotat", "BUSCASUBMOD", "Submodalidades", "30", filtros, colunas, '', '$(\'#cdsubmod\',\'#frmLrotat\').val();', 'frmLrotat');

    $("#divCabecalhoPesquisa > table").css("width", "600px");
    $("#divResultadoPesquisa > table").css("width", "600px");
    $("#divCabecalhoPesquisa").css("width", "600px");
    $("#divResultadoPesquisa").css("width", "600px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}
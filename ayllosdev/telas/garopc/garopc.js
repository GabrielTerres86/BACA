/*!
 * FONTE        : garopc.js
 * CRIACAO      : Jaison Fernando
 * DATA CRIACAO : Novembro/2017
 * OBJETIVO     : Biblioteca de funcoes da tela

   Alteracoes   : 18/12/2017 - P404 - Inclusão de Garantia de Cobertura das Operações de Crédito (Augusto / Marcos (Supero))
                  23/03/2019 - PRJ 438 - BUG 18068 - Atualizar flag de alteração para sempre validar se houve ou não alteração
                               nos valores em tela - Bruno Luiz Katzjarowski - Mout's
				  19/04/2019 - Ajuste na tela garantia de operação, para salvar seus dados apenas no 
                               final da inclusão, alteração de empréstimo - PRJ 438. (Mateus Z / Mouts)
 */

$(document).ready(function() {

	$('fieldset > legend', "#frmGAROPC").css({'font-size':'11px','color':'#777','margin-left':'5px','padding':'0px 8px 0px 8px'});
	$('fieldset', "#frmGAROPC").css({'clear':'both','border':'1px solid #969FA9','margin':'8px','padding':'10px 3px 5px 3px'});
    
    $('#divUsoGAROPC').css({'width':'575px','position':'absolute','display':'inline','z-index':'110'});
    $('#divUsoGAROPC').centralizaRotinaH();

    /*$(this).keyup(function(e){
        if (e.which == 27) {
            $('#btVoltar', '#divUsoGAROPC').click();
        }
    });*/

    return false;

});


var rGar_rotulos1 = $('label[for="gar_vlropera"],label[for="gar_codlinha"],label[for="gar_permingr"],label[for="gar_pro_apli"],label[for="gar_pro_poup"],label[for="gar_pro_raut"],label[for="gar_ter_ncta"],label[for="gar_ter_apli"],label[for="gar_ter_poup"]', '#frmGAROPC');
var rGar_rotulos2 = $('label[for="gar_pro_apli_0"],label[for="gar_pro_apli_1"],label[for="gar_pro_poup_0"],label[for="gar_pro_poup_1"],label[for="gar_pro_raut_0"],label[for="gar_pro_raut_1"],label[for="gar_ter_apli_0"],label[for="gar_ter_apli_1"],label[for="gar_ter_poup_0"],label[for="gar_ter_poup_1"]', '#frmGAROPC');
var rGar_rotulos3 = $('label[for="gar_pro_apli_sld"],label[for="gar_pro_poup_sld"]', '#frmGAROPC');

rGar_rotulos1.addClass('rotulo').css({'width': '150px'});
rGar_rotulos2.addClass('rotulo').css({'width': '25px'});
rGar_rotulos3.addClass('rotulo-linha').css({'width': '140px'});

var cGar_campos1 = $('#gar_vlropera,#gar_vlgarnec,#gar_pro_apli_sld,#gar_pro_poup_sld', '#frmGAROPC');
var cGar_campos2 = $('input[name=gar_pro_apli]:radio, input[name=gar_pro_poup]:radio', '#frmGAROPC');
var cGar_campos3 = $('input[name=gar_ter_apli]:radio, input[name=gar_ter_poup]:radio', '#frmGAROPC');
var cGar_codlinha = $('#gar_codlinha', '#frmGAROPC');
var cGar_deslinha = $('#gar_deslinha', '#frmGAROPC');
var cGar_permingr = $('#gar_permingr', '#frmGAROPC');
var cGar_ter_ncta = $('#gar_ter_ncta', '#frmGAROPC');
var cGar_ter_nome = $('#gar_ter_nome', '#frmGAROPC');
var cGar_tipaber  = $('#gar_tipaber',  '#frmGAROPC');
var cGar_lintpctr = $('#gar_lintpctr', '#frmGAROPC');
var cGar_vlgarnec = $('#gar_vlgarnec', '#frmGAROPC');
var cGar_pro_raut = $('input[name=gar_pro_raut]:radio', '#frmGAROPC');

cGar_campos1.addClass('campo').css({'width':'120px','text-align':'right'});
cGar_codlinha.addClass('campo').css({'width':'50px','text-align':'right'});
cGar_deslinha.addClass('campo').css({'width':'300px'});
cGar_permingr.addClass('campo').css({'width':'50px','text-align':'right'});
cGar_ter_ncta.addClass('campo conta').css({'width':'80px'});
cGar_ter_nome.addClass('campo').css({'width':'250px'});

$('#frmGAROPC a').css({'padding':'3px 6px'});

// Bloqueia todos os campos
$('input[type="text"],input[type="radio"]','#frmGAROPC').desabilitaCampo();

// Esconde imagem e reseta o link da lupa
$('#imgGAROPC', '#frmGAROPC').hide();
$('#btLupaAssociado', '#frmGAROPC').attr('onClick','return false;');

// Se NAO for Consulta
if (cGar_tipaber.val() != 'C') {

    var gar_vlropera = $('#gar_vlropera', '#frmGAROPC').val();
    var gar_vlropera_float = converteMoedaFloat(gar_vlropera);
    var gar_inresper = normalizaNumero($('#gar_inresper', '#frmGAROPC').val());
    var gar_inresaut = normalizaNumero($('#gar_inresaut', '#frmGAROPC').val());
    var gar_tpctrato = normalizaNumero($('#gar_tpctrato', '#frmGAROPC').val());

    cGar_ter_ncta.habilitaCampo();
    cGar_campos2.habilitaCampo();
    $('#imgGAROPC', '#frmGAROPC').show();
    $('#btLupaAssociado', '#frmGAROPC').attr('onClick','pesquisaAssociadoGAROPC(); return false;');

    // Se estiver parametrizado para habilitar o resgate automático habilita o campo
    if (gar_inresper == 1) {
        cGar_pro_raut.habilitaCampo();
    }

    // Somente permite caso foi informado conta de terceiro
    if (normalizaNumero(cGar_ter_ncta.val()) > 0) {
        cGar_campos3.habilitaCampo();
    }

    // Se foi clicado nos campos de aplicacao/poupanca
    cGar_campos2.unbind('click').bind('click', function (){
        mostraImagemGAROPC(1);
        limpaCamposGAROPC('T');
        // Se NAO foi selecionado aplicacao propria reseta o resgate automatico
        if ($('input[name=gar_pro_apli]:radio:checked', '#frmGAROPC').val() == 0) {
            $('#gar_pro_raut_0').prop("checked", true);
        }
    });

    // Se foi clicado no campo resgate automatico
    cGar_pro_raut.unbind('click').bind('click', function (){
        limpaCamposGAROPC('T');
    });

    // Se foi clicado nos campos de aplicacao/poupanca de terceiro
    cGar_campos3.unbind('click').bind('click', function (){
        mostraImagemGAROPC(1);
        limpaCamposGAROPC('P');
    });

    // Se foi alterado a conta de terceiro
    cGar_ter_ncta.unbind('blur').bind('blur', function (){
        var gar_ter_ncta = normalizaNumero($(this).val());
        // Se informou conta
        if (gar_ter_ncta > 0) {

            var gar_filtros = 'cdcooper|' + $('#gar_cdcooper', '#frmGAROPC').val() + ';' + 'nrdconta|' + gar_ter_ncta;
            buscaDescricao("ZOOM0001", "BUSCADESCASSOCIADO", "Pesquisa Associados", $(this).attr('name'), 'gar_ter_nome', gar_ter_ncta, 'nmprimtl', gar_filtros, 'frmGAROPC');

            // Carrega conteudo da opcao atraves do Ajax
            $.ajax({
                type: 'POST',
                dataType: 'html',
                url: UrlSite + 'telas/garopc/busca_saldos.php',
                data: {
                    nrdconta : gar_ter_ncta,
                    tpctrato : gar_tpctrato,
                    nrctaliq : normalizaNumero($('#gar_nrdconta', '#frmGAROPC').val()),
                    dsctrliq : $('#gar_dsctrliq', '#frmGAROPC').val(),
                    redirect : 'html_ajax'
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo($(\'#frmGAROPC\'))');
                },
                success: function (response) {
                    eval(response);
                    $('#gar_ter_apli_0').prop("checked", true);
                    $('#gar_ter_poup_0').prop("checked", true);
                    mostraImagemGAROPC(0);
                }
            });

            cGar_campos3.habilitaCampo();
            limpaCamposGAROPC('P');
            setTimeout('bloqueiaFundo($(\'#frmGAROPC\'));', 550);

        } else {
            limpaCamposGAROPC('T');
        }
    });

    // Se NAO for uma linha com Modelo = 4 (Aplicacao)
    if (normalizaNumero( cGar_lintpctr.val() ) != 4) {
        cGar_vlgarnec.habilitaCampo().setMask("DECIMAL","zzz.zzz.zz9,99","","");
        // Se foi alterado valor da garantia necessaria
        cGar_vlgarnec.unbind('blur').bind('blur', function(){
			var gar_vlgarnec_new = converteMoedaFloat($(this).val());
            var gar_permingr_new = (gar_vlgarnec_new / gar_vlropera_float) * 100;

            // Se zerou marcar como NAO aplicacao e poupanca
            if (gar_vlgarnec_new == 0) {
                $('#gar_pro_apli_0').prop("checked", true);
                $('#gar_pro_poup_0').prop("checked", true);
                $('#gar_ter_apli_0').prop("checked", true);
                $('#gar_ter_poup_0').prop("checked", true);
            }

            // Calcula os valores
            gar_permingr_new = Math.round(gar_permingr_new * 100) / 100;
            gar_vlgarnec_new = (gar_permingr_new / 100) * gar_vlropera_float;

            // Carrega valores nos campos
            $(this).val(number_format(gar_vlgarnec_new,2,',','.'));
            cGar_permingr.val(number_format(gar_permingr_new,2,',','.'));

            mostraImagemGAROPC(0);
		});
    }
}

function pesquisaAssociadoGAROPC() {
    mostraPesquisaAssociado('gar_ter_ncta|gar_ter_nome', 'frmGAROPC', 'frmGAROPC', '');
    $('#divPesquisaAssociado').css('z-index', 150);
    bloqueiaFundo($('#divPesquisaAssociado'));
}

function limpaCamposGAROPC(gar_tipoapli) {
    if (gar_tipoapli == 'T') { // Limpar Terceiro
        cGar_ter_ncta.val('');
        cGar_ter_nome.val('');
        $('#gar_ter_apli_0').prop("checked", true);
        $('#gar_ter_poup_0').prop("checked", true);
        cGar_campos3.desabilitaCampo();
    } else if (gar_tipoapli == 'P') { // Limpar Propria
        $('#gar_pro_apli_0').prop("checked", true);
        $('#gar_pro_poup_0').prop("checked", true);
        $('#gar_pro_raut_0').prop("checked", true);
    }
    mostraImagemGAROPC(0);
}

function mostraImagemGAROPC(gar_invalida) {
    var gar_vlselect = 0;
    var gar_urlimage = $('#imgGAROPC', '#frmGAROPC').attr('urlimage');
    var gar_nomimage = 'motor_REPROVAR.png';
    var gar_altimage = 'Valor de garantia insuficiente!';
    var gar_pro_apli = $('input[name=gar_pro_apli]:radio:checked', '#frmGAROPC').val();
    var gar_pro_poup = $('input[name=gar_pro_poup]:radio:checked', '#frmGAROPC').val();
    var gar_ter_apli = $('input[name=gar_ter_apli]:radio:checked', '#frmGAROPC').val();
    var gar_ter_poup = $('input[name=gar_ter_poup]:radio:checked', '#frmGAROPC').val();

    // Se foi selecionado aplicacao
    if (gar_pro_apli == 1) {
        gar_vlselect = gar_vlselect + converteMoedaFloat($('#gar_pro_apli_sld', '#frmGAROPC').val());
    }

    // Se foi selecionado poupanca
    if (gar_pro_poup == 1) {
        gar_vlselect = gar_vlselect + converteMoedaFloat($('#gar_pro_poup_sld', '#frmGAROPC').val());
    }

    // Se foi selecionado aplicacao de terceiro
    if (gar_ter_apli == 1) {
        gar_vlselect = gar_vlselect + converteMoedaFloat($('#gar_ter_apli_sld', '#frmGAROPC').val());
    }

    // Se foi selecionado poupanca de terceiro
    if (gar_ter_poup == 1) {
        gar_vlselect = gar_vlselect + converteMoedaFloat($('#gar_ter_poup_sld', '#frmGAROPC').val());
    }

    // Se nao foi selecionado nenhuma opcao e for necessario validar
    if (gar_pro_apli == 0 && 
        gar_pro_poup == 0 && 
        gar_ter_apli == 0 && 
        gar_ter_poup == 0 && 
        gar_invalida == 1) {
        var gar_vlr_permingr = converteMoedaFloat($('#gar_permingr', '#frmGAROPC').attr('vlr_permingr'));
        var gar_permingr_new = gar_vlropera_float * (gar_vlr_permingr / 100);
        cGar_vlgarnec.val(number_format(gar_permingr_new,2,',','.'));
        cGar_permingr.val(number_format(gar_vlr_permingr,2,',','.'));
    }

    // Se Garantia Necessaria for menor ou igual ao valor selecionado
    if (converteMoedaFloat(cGar_vlgarnec.val()) <= gar_vlselect) {
        gar_nomimage = 'motor_APROVAR.png';
        gar_altimage = 'Garantia atingida!';
    }

    $('#imgGAROPC', '#frmGAROPC').attr('src', gar_urlimage + gar_nomimage);
    $('#imgGAROPC', '#frmGAROPC').attr('title', gar_altimage);
}
 
function gravarGAROPC(gar_ret_nomcampo, gar_ret_nomformu, gar_ret_execfunc, gar_err_execfunc) {

    var gar_nmdatela = $('#gar_nmdatela', '#frmGAROPC').val();
    var gar_idcobert = normalizaNumero($('#gar_idcobert', '#frmGAROPC').val());
    var gar_nrdconta = normalizaNumero($('#gar_nrdconta', '#frmGAROPC').val());
    var gar_diatrper = normalizaNumero($('#gar_diatrper', '#frmGAROPC').val());
    var gar_pro_apli = $('input[name=gar_pro_apli]:radio:checked', '#frmGAROPC').val();
    var gar_pro_poup = $('input[name=gar_pro_poup]:radio:checked', '#frmGAROPC').val();
    var gar_pro_raut = $('input[name=gar_pro_raut]:radio:checked', '#frmGAROPC').val();
    var gar_ter_apli = $('input[name=gar_ter_apli]:radio:checked', '#frmGAROPC').val();
    var gar_ter_poup = $('input[name=gar_ter_poup]:radio:checked', '#frmGAROPC').val();

    var gar_pro_apli_sld = $('#gar_pro_apli_sld', '#frmGAROPC').val();
    var gar_pro_poup_sld = $('#gar_pro_poup_sld', '#frmGAROPC').val();
    var gar_ter_apli_sld = $('#gar_ter_apli_sld', '#frmGAROPC').val();
    var gar_ter_poup_sld = $('#gar_ter_poup_sld', '#frmGAROPC').val();

    // Carrega conteudo da opcao atraves do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/garopc/grava_dados.php',
        data: {
            nmdatela     : gar_nmdatela,
            idcobert     : gar_idcobert,
            tipaber      : cGar_tipaber.val(),
            nrdconta     : gar_nrdconta,
            nrctater     : normalizaNumero(cGar_ter_ncta.val()),
            lintpctr     : cGar_lintpctr.val(),
            vlropera     : gar_vlropera,
            permingr     : cGar_permingr.val(),
            inresper     : gar_inresper,
            diatrper     : gar_diatrper,
            tpctrato     : gar_tpctrato,
            inaplpro     : gar_pro_apli,
            vlaplpro     : gar_pro_apli_sld,
            inpoupro     : gar_pro_poup,
            vlpoupro     : gar_pro_poup_sld,
            inresaut     : gar_pro_raut,
            inaplter     : gar_ter_apli,
            vlaplter     : gar_ter_apli_sld,
            inpouter     : gar_ter_poup,
            vlpouter     : gar_ter_poup_sld,
            ret_nomcampo : gar_ret_nomcampo,
            ret_nomformu : gar_ret_nomformu,
            ret_execfunc : gar_ret_execfunc,
            err_execfunc : gar_err_execfunc,
            redirect     : 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo($(\'#frmGAROPC\'))');
        },
        success: function (response) {
            eval(response);
        }
    });

}

function validarGAROPC(gar_ret_execfunc, gar_err_execfunc) {

    var gar_nmdatela = $('#gar_nmdatela', '#frmGAROPC').val();
    var gar_idcobert = normalizaNumero($('#gar_idcobert', '#frmGAROPC').val());
    var gar_nrdconta = normalizaNumero($('#gar_nrdconta', '#frmGAROPC').val());
    var gar_diatrper = normalizaNumero($('#gar_diatrper', '#frmGAROPC').val());
    var gar_pro_apli = $('input[name=gar_pro_apli]:radio:checked', '#frmGAROPC').val();
    var gar_pro_poup = $('input[name=gar_pro_poup]:radio:checked', '#frmGAROPC').val();
    var gar_pro_raut = $('input[name=gar_pro_raut]:radio:checked', '#frmGAROPC').val();
    var gar_ter_apli = $('input[name=gar_ter_apli]:radio:checked', '#frmGAROPC').val();
    var gar_ter_poup = $('input[name=gar_ter_poup]:radio:checked', '#frmGAROPC').val();

    var gar_pro_apli_sld = $('#gar_pro_apli_sld', '#frmGAROPC').val();
    var gar_pro_poup_sld = $('#gar_pro_poup_sld', '#frmGAROPC').val();
    var gar_ter_apli_sld = $('#gar_ter_apli_sld', '#frmGAROPC').val();
    var gar_ter_poup_sld = $('#gar_ter_poup_sld', '#frmGAROPC').val();

    // PRJ 438 - Salvar os campos para serem gravados ao final da tela Emprestimo
    campos_garopc_emp = {
        nmdatela: gar_nmdatela,
        idcobert: gar_idcobert,
        tipaber:  cGar_tipaber.val(),
        nrdconta: gar_nrdconta,
        nrctater: normalizaNumero(cGar_ter_ncta.val()),
        lintpctr: cGar_lintpctr.val(),
        vlropera: gar_vlropera,
        permingr: cGar_permingr.val(),
        inresper: gar_inresper,
        diatrper: gar_diatrper,
        tpctrato: gar_tpctrato,
        inaplpro: gar_pro_apli,
        vlaplpro: gar_pro_apli_sld,
        inpoupro: gar_pro_poup,
        vlpoupro: gar_pro_poup_sld,
        inresaut: gar_pro_raut,
        inaplter: gar_ter_apli,
        vlaplter: gar_ter_apli_sld,
        inpouter: gar_ter_poup,
        vlpouter: gar_ter_poup_sld
    };

    // PRJ 438
    flgPassouGAROPC = true;

    // Carrega conteudo da opcao atraves do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/garopc/valida_dados.php',
        data: {
            nmdatela     : gar_nmdatela,
            tipaber      : cGar_tipaber.val(),
            nrdconta     : gar_nrdconta,
            nrctater     : normalizaNumero(cGar_ter_ncta.val()),
            lintpctr     : cGar_lintpctr.val(),
            vlropera     : gar_vlropera,
            permingr     : cGar_permingr.val(),
            inresper     : gar_inresper,
            diatrper     : gar_diatrper,
            tpctrato     : gar_tpctrato,
            inaplpro     : gar_pro_apli,
            vlaplpro     : gar_pro_apli_sld,
            inpoupro     : gar_pro_poup,
            vlpoupro     : gar_pro_poup_sld,
            inresaut     : gar_pro_raut,
            inaplter     : gar_ter_apli,
            vlaplter     : gar_ter_apli_sld,
            inpouter     : gar_ter_poup,
            vlpouter     : gar_ter_poup_sld,
            ret_execfunc : gar_ret_execfunc,
            err_execfunc : gar_err_execfunc,
            redirect     : 'html_ajax'
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo($(\'#frmGAROPC\'))');
        },
        success: function (response) {
            eval(response);
        }
    });

}

/***********************************************************************
 Fonte: cadcop.js
 Autor: Andrei - RKAM
 Data : Agosto/2016                Última Alteração: 26/01/2016

 Objetivo  : Cadastro de servicos ofertados na tela CADCOP

 Alterações: 17/11/2016 - M172 Atualizacao Telefone - Novo campo (Guilherme/SUPERO)

             30/11/2016 - P341-Automatização BACENJUD - Incluir a variável cddepart no fonte
                          e utilizar a mesma para validação no lugar da DSDEPART (Renato Darosci - Supero)

             26/01/2016 - Correcao na forma de recuperação do campo flgofatr do form de tela. (SD 601029 Carlos R. Tanholi)

************************************************************************/
var cddepart;

$(document).ready(function() {

    estadoInicial();

});

function estadoInicial() {

    formataCabecalho();

    $('#cddopcao', '#frmCab').habilitaCampo().focus().val('C');
    $('#divBotoes').css({ 'display': 'none' });
    $('#frmFiltro').css('display', 'none');
    $('#divTabela').html('').css('display','none');

}


function formataCabecalho() {

    // rotulo
    $('label[for="cddopcao"]', "#frmCab").addClass("rotulo").css({ "width": "45px" });

    // campo
    $("#cddopcao", "#frmCab").css("width", "530px").habilitaCampo();

    $('#divTela').css({ 'display': 'block' }).fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCab').css({ 'display': 'block' });
    highlightObjFocus($('#frmCab'));

    $('input[type="text"],select', '#frmCab').limpaFormulario().removeClass('campoErro');

    //Define ação para ENTER e TAB no campo Opção
    $("#cddopcao", "#frmCab").unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {

            $("#btnOK", "#frmCab").click();

            return false;

        }

    });

    //Define ação para CLICK no botão de OK
    $("#btnOK", "#frmCab").unbind('click').bind('click', function () {

        // Se esta desabilitado o campo
        if ($("#cddopcao", "#frmCab").prop("disabled") == true) {
            return false;
        }

        $('#cddopcao', '#frmCab').desabilitaCampo();

        if ($('#cddopcao', '#frmCab').val() == 'C') {

            consultaCooperativa();

        } else if ($('#cddopcao', '#frmCab').val() == 'M') {

            consultaMunicipios('1', '30');

        } else if ($('#cddopcao', '#frmCab').val() == 'A') {

            /* critica para permitir somente os seguintes operadores  */
            if(cddepart != 1   &&   // CANAIS
               cddepart != 4   &&   // COMPE
               cddepart != 6   &&   // CONTABILIDADE
               cddepart != 7   &&   // CONTROLE
               cddepart != 8   &&   // COORD.ADM/FINANCEIRO
               cddepart != 9   &&   // COORD.PRODUTOS
               cddepart != 14  &&   // PRODUTOS
               cddepart != 18  &&   // SUPORTE
               cddepart != 20 ) {   // TI

                showError("error", "Opera&ccedil;&atilde;o n&atilde;o autorizada.", "Alerta - Ayllos", "estadoInicial();");

            }else{

                consultaCooperativa();

            }

        }

        $(this).unbind('click');

        return false;

    });

    layoutPadrao();

    return false;
}

function formataFormularioIncluir() {

    //rotulo
    $('label[for="dscidade"]', "#frmIncluir").addClass("rotulo").css({ "width": "100px" });
    $('label[for="cdestado"]', "#frmIncluir").addClass("rotulo").css({ "width": "100px" });

    // campo
    $('#dscidade', '#frmIncluir').addClass('alpha').css({ 'width': '350px', 'text-align': 'left' }).attr('maxlength', '50').habilitaCampo();
    $('#cdestado', '#frmIncluir').addClass('alpha').css({ 'width': '80px', 'text-align': 'left' }).attr('maxlength', '2').habilitaCampo();

    $('#frmIncluir').limpaFormulario();
    $('input,select').removeClass('campoErro');

    $('#divIncluir').css({ 'display': 'block' });
    $('#frmIncluir').css({ 'display': 'block' });
    $('#divBotoesIncluir').css({ 'display': 'block' });
    $('#btVoltar', '#divBotoesIncluir').css({ 'display': 'inline' });
    $('#btConcluir', '#divBotoesIncluir').css({ 'display': 'inline' });

    highlightObjFocus($('#frmIncluir'));

    // Se pressionar dscidade
    $('#dscidade', '#frmIncluir').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $("#cdestado", "#frmIncluir").focus();

            return false;

        }

    });

    // Se pressionar cdestado
    $('#cdestado', '#frmIncluir').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $("#btConcluir", "#divBotoesIncluir").click();

            return false;

        }

    });

    //Define ação para CLICK no botão de Concluir
    $("#btConcluir", "#divBotoesIncluir").unbind('click').bind('click', function () {

        showConfirmacao('Deseja confirmar opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'incluirMunicipios(\'I\');', '$(\'#btVoltar\',\'#divBotoesIncluir\').focus();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));', 'sim.gif', 'nao.gif');

        return false;

    });

    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoesIncluir").unbind('click').bind('click', function () {

        fechaRotina($('#divRotina'));

        return false;

    });

    $("#dscidade", "#frmIncluir").focus();

    layoutPadrao();

}

function formataFormularioConsulta() {

    highlightObjFocus($('#frmConsulta'));
    highlightObjFocus($('#frmConsulta2'));
    highlightObjFocus($('#frmConsulta3'));
    highlightObjFocus($('#frmConsulta4'));
    highlightObjFocus($('#frmConsulta5'));

    //rotulo
    $('label[for="cdcooper"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="nrdocnpj"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="dtcdcnpj"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "75px" });
    $('label[for="nmextcop"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="dsendcop"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="nrendcop"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "60px" });
    $('label[for="dscomple"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="nmbairro"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="nrcepend"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "45px" });
    $('label[for="nmcidade"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="cdufdcop"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "45px" });
    $('label[for="nrcxapst"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="nrtelvoz"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="nrtelouv"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "210px" });
    $('label[for="dsendweb"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="nrtelura"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "60px" });
    $('label[for="dsdemail"]', "#frmConsulta").addClass("rotulo").css({ "width": "100px" });
    $('label[for="nrtelfax"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "60px" });
    $('label[for="dsdempst"]', "#frmConsulta").addClass("rotulo").css({ "width": "120px" });
    $('label[for="nrtelsac"]', "#frmConsulta").addClass("rotulo-linha").css({ "width": "40px" });

    $('label[for="nmtitcop"]', "#frmConsulta").addClass("rotulo").css({ "width": "180px" });
    $('label[for="nrcpftit"]', "#frmConsulta").addClass("rotulo").css({ "width": "180px" });

    $('label[for="nmctrcop"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrcpfctr"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrcrcctr"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "120px" });
    $('label[for="dsemlctr"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrrjunta"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dtrjunta"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "140px" });
    $('label[for="nrinsest"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrinsmun"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "110px" });
    $('label[for="nrlivapl"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrlivcap"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "170px" });
    $('label[for="nrlivdpv"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrlivepr"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "170px" });

    $('label[for="cdbcoctl"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="cdagectl"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="cddigage"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "10px" });
    $('label[for="flgdsirc"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="flgopstr"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="iniopstr"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "80px" });
    $('label[for="fimopstr"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "50px" });
    $('label[for="flgoppag"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="inioppag"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "80px" });
    $('label[for="fimoppag"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "50px" });
    $('label[for="flgvrbol"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="hhvrbini"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "80px" });
    $('label[for="hhvrbfim"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "50px" });
    $('label[for="cdagebcb"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="cdagedbb"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="cdageitg"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="cdcnvitg"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="cdmasitg"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dssigaut"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="nrctabbd"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrctactl"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="nrctaitg"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrctadbb"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="nrctacmp"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrdconta"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="flgcrmag"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="qtdiaenl"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="cdsinfmg"]', "#frmConsulta2").addClass("rotulo").css({ "width": "150px" });
    $('label[for="taamaxer"]', "#frmConsulta2").addClass("rotulo-linha").css({ "width": "160px" });

    $('label[for="flgcmtlc"]', "#frmConsulta3").addClass("rotulo").css({ "width": "180px" });
    $('label[for="vllimapv"]', "#frmConsulta3").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="cdcrdarr"]', "#frmConsulta3").addClass("rotulo").css({ "width": "180px" });
    $('label[for="cdagsede"]', "#frmConsulta3").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="vlmaxcen"]', "#frmConsulta3").addClass("rotulo").css({ "width": "180px" });
    $('label[for="vlmaxleg"]', "#frmConsulta3").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="vlmaxutl"]', "#frmConsulta3").addClass("rotulo").css({ "width": "180px" });
    $('label[for="vlcnsscr"]', "#frmConsulta3").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="vllimmes"]', "#frmConsulta3").addClass("rotulo").css({ "width": "180px" });
    $('label[for="nrctabol"]', "#frmConsulta3").addClass("rotulo").css({ "width": "180px" });
    $('label[for="cdlcrbol"]', "#frmConsulta3").addClass("rotulo-linha").css({ "width": "180px" });

    $('label[for="dsclactr"]', "#frmConsulta3").addClass("rotulo").css({ "width": "150px" });

    $('label[for="dsclaccb"]', "#frmConsulta3").addClass("rotulo").css({ "width": "180px" });

    $('label[for="dsdircop"]', "#frmConsulta3").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nmdireto"]', "#frmConsulta3").addClass("rotulo").css({ "width": "150px" });
    $('label[for="flgdopgd"]', "#frmConsulta3").addClass("rotulo").css({ "width": "150px" });
    $('label[for="hrproces"]', "#frmConsulta3").addClass("rotulo").css({ "width": "150px" });
    $('label[for="hrfinprc"]', "#frmConsulta3").addClass("rotulo-linha").css({ "width": "80px" });
    $('label[for="dsnotifi"]', "#frmConsulta3").addClass("rotulo").css({ "width": "150px" });

    $('label[for="nrconven"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrversao"]', "#frmConsulta4").addClass("rotulo-linha").css({ "width": "150px" });
    $('label[for="vldataxa"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });
    $('label[for="vltxinss"]', "#frmConsulta4").addClass("rotulo-linha").css({ "width": "150px" });
    $('label[for="flgargps"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });

    $('label[for="dtctrdda"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrctrdda"]', "#frmConsulta4").addClass("rotulo-linha").css({ "width": "150px" });
    $('label[for="idlivdda"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrfoldda"]', "#frmConsulta4").addClass("rotulo-linha").css({ "width": "110px" });
    $('label[for="dslocdda"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dsciddda"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });

    $('label[for="dtregcob"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });
    $('label[for="idregcob"]', "#frmConsulta4").addClass("rotulo-linha").css({ "width": "150px" });
    $('label[for="idlivcob"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });
    $('label[for="nrfolcob"]', "#frmConsulta4").addClass("rotulo-linha").css({ "width": "110px" });
    $('label[for="dsloccob"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dscidcob"]', "#frmConsulta4").addClass("rotulo").css({ "width": "150px" });

    $('label[for="dsnomscr"]', "#frmConsulta5").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dsemascr"]', "#frmConsulta5").addClass("rotulo").css({ "width": "150px" });
    $('label[for="dstelscr"]', "#frmConsulta5").addClass("rotulo").css({ "width": "150px" });

    $('label[for="cdagesic"]', "#frmConsulta5").addClass("rotulo").css({ "width": "200px" });
    $('label[for="nrctasic"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "150px" });
    $('label[for="cdcrdins"]', "#frmConsulta5").addClass("rotulo").css({ "width": "200px" });
    $('label[for="vltarsic"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "150px" });
    $('label[for="vltardrf"]', "#frmConsulta5").addClass("rotulo").css({ "width": "200px" });
    $('label[for="vltfcxsb"]', "#frmConsulta5").addClass("rotulo").css({ "width": "200px" });
    $('label[for="vltfcxcb"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "200px" });
    $('label[for="vlrtrfib"]', "#frmConsulta5").addClass("rotulo").css({ "width": "200px" });
    $('label[for="hrinigps"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "150px" });
    $('label[for="hrfimgps"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "35px" });
    $('label[for="hrlimsic"]', "#frmConsulta5").addClass("rotulo").css({ "width": "200px" });

    $('label[for="qttmpsgr"]', "#frmConsulta5").addClass("rotulo").css({ "width": "150px" });
    $('label[for="flgkitbv"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "180px" });

    $('label[for="qtdiasus"]', "#frmConsulta5").addClass("rotulo").css({ "width": "300px" });
    $('label[for="hriniatr"]', "#frmConsulta5").addClass("rotulo").css({ "width": "300px" });
    $('label[for="hrfimatr"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "35px" });
    $('label[for="flgofatr"]', "#frmConsulta5").addClass("rotulo").css({ "width": "300px" });

    $('label[for="cdcliser"]', "#frmConsulta5").addClass("rotulo").css({ "width": "150px" });

    $('label[for="vlmiplco"]', "#frmConsulta5").addClass("rotulo").css({ "width": "220px" });
    $('label[for="vlmidbco"]', "#frmConsulta5").addClass("rotulo").css({ "width": "220px" });

    $('label[for="cdfingrv"]', "#frmConsulta5").addClass("rotulo").css({ "width": "150px" });
    $('label[for="cdsubgrv"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "180px" });
    $('label[for="cdloggrv"]', "#frmConsulta5").addClass("rotulo").css({ "width": "150px" });

    $('label[for="flsaqpre"]', "#frmConsulta5").addClass("rotulo").css({ "width": "150px" });

    $('label[for="permaxde"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "250px" });
    $('label[for="qtmaxmes"]', "#frmConsulta5").addClass("rotulo").css({ "width": "250px" });
    $('label[for="qtmeatel"]', "#frmConsulta5").addClass("rotulo").css({ "width": "250px" });
    $('label[for="flrecpct"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "140px" });
    $('label[for="hrinisac"]', "#frmConsulta5").addClass("rotulo").css({ "width": "80px" });
    $('label[for="hrfimsac"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "50px" });
    $('label[for="hriniouv"]', "#frmConsulta5").addClass("rotulo").css({ "width": "80px" });
    $('label[for="hrfimouv"]', "#frmConsulta5").addClass("rotulo-linha").css({ "width": "50px" });


    // campo
    $("#cdcooper", "#frmConsulta").css({ 'width': '60px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '4').desabilitaCampo();
    $("#nmrescop", "#frmConsulta").css({ 'width': '420px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '20').desabilitaCampo();
    $('#nrdocnpj', '#frmConsulta').css({ 'width': '170px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '18');
    $('#dtcdcnpj', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('data');
    $('#nmextcop', '#frmConsulta').css({ 'width': '480px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '50').desabilitaCampo();
    $('#dsendcop', '#frmConsulta').css({ 'width': '330px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '40').desabilitaCampo();
    $('#nrendcop', '#frmConsulta').css({ 'width': '85px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '6').setMask("INTEGER", "zz.zzz", "", "");
    $('#dscomple', '#frmConsulta').css({ 'width': '480px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '50').desabilitaCampo();
    $('#nmbairro', '#frmConsulta').css({ 'width': '330px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '15').desabilitaCampo();
    $('#nrcepend', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '10').setMask("INTEGER", "zz.zzz.zzz", "", "");
    $('#nmcidade', '#frmConsulta').css({ 'width': '330px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '25').desabilitaCampo();
    $('#cdufdcop', '#frmConsulta').css({ 'width': '50px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '2').desabilitaCampo();
    $('#nrcxapst', '#frmConsulta').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '6').setMask("INTEGER", "zz.zzz", "", "");
    $('#nrtelvoz', '#frmConsulta').css({ 'width': '120px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '15').desabilitaCampo();
    $('#nrtelouv', '#frmConsulta').css({ 'width': '145px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '20').desabilitaCampo();
    $('#dsendweb', '#frmConsulta').css({ 'width': '270px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '34').desabilitaCampo();
    $('#nrtelura', '#frmConsulta').css({ 'width': '145px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '20').desabilitaCampo();
    $('#dsdemail', '#frmConsulta').css({ 'width': '270px', 'text-align': 'left' }).addClass('email').attr('maxlength', '34').desabilitaCampo();
    $('#nrtelfax', '#frmConsulta').css({ 'width': '145px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '15').desabilitaCampo();
    $('#dsdempst', '#frmConsulta').css({ 'width': '270px', 'text-align': 'left' }).addClass('email').attr('maxlength', '30').desabilitaCampo();
    $('#nrtelsac', '#frmConsulta').css({ 'width': '145px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '20').desabilitaCampo();

    $('#nmtitcop', '#frmConsulta').css({ 'width': '400px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '40').desabilitaCampo();
    $('#nrcpftit', '#frmConsulta').css({ 'width': '160px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '11');

    $('#nmctrcop', '#frmConsulta2').css({ 'width': '420px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '40').desabilitaCampo();
    $('#nrcpfctr', '#frmConsulta2').css({ 'width': '150px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '11');
    $('#nrcrcctr', '#frmConsulta2').css({ 'width': '145px', 'text-align': 'right' }).addClass('alphanum').attr('maxlength', '20').desabilitaCampo();
    $('#dsemlctr', '#frmConsulta2').css({ 'width': '420px', 'text-align': 'left' }).addClass('email').attr('maxlength', '40').desabilitaCampo();
    $('#nrrjunta', '#frmConsulta2').css({ 'width': '130px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '15').setMask("INTEGER", "zzz.zzz.zzzz.z", "", "");
    $('#dtrjunta', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('data');
    $('#nrinsest', '#frmConsulta2').css({ 'width': '160px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '17').setMask("INTEGER", "zzz.zzz.zzz.zzz.z", "", "");
    $('#nrinsmun', '#frmConsulta2').css({ 'width': '160px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '17').setMask("INTEGER", "zzz.zzz.zzz.zzz.z", "", "");
    $('#nrlivapl', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '7').setMask("INTEGER", "zzz.zzz", "", "");
    $('#nrlivcap', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '7').setMask("INTEGER", "zzz.zzz", "", "");
    $('#nrlivdpv', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '7').setMask("INTEGER", "zzz.zzz", "", "");
    $('#nrlivepr', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '7').setMask("INTEGER", "zzz.zzz", "", "");

    $('#cdbcoctl', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '3').desabilitaCampo();
    $('#cdagectl', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '4').desabilitaCampo();
    $('#cddigage', '#frmConsulta2').css({ 'width': '35px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '1').desabilitaCampo();
    $('#flgdsirc', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#flgopstr', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#iniopstr', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#fimopstr', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#flgoppag', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#inioppag', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#fimoppag', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#flgvrbol', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#hhvrbini', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#hhvrbfim', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#cdagebcb', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '6').setMask("INTEGER", "zz.zzz", "", "");
    $('#cdagedbb', '#frmConsulta2').css({ 'width': '140px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $('#cdageitg', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '4').desabilitaCampo();
    $('#cdcnvitg', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '9').desabilitaCampo();
    $('#cdmasitg', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '5').desabilitaCampo();
    $('#dssigaut', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).addClass('alpha').attr('maxlength', '4').desabilitaCampo();
    $('#nrctabbd', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '10').setMask("INTEGER", "zzzz.zzz.z", "", "");
    $('#nrctactl', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '10').setMask("INTEGER", "zzzz.zzz.z", "", "");
    $('#nrctaitg', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '8').desabilitaCampo();
    $('#nrctadbb', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '10').setMask("INTEGER", "zzzz.zzz.z", "", "");
    $('#nrctacmp', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '10').setMask("INTEGER", "zzzz.zzz.z", "", "");
    $('#nrdconta', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '10').setMask("INTEGER", "zzzz.zzz.z", "", "");
    $('#flgcrmag', '#frmConsulta2').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#qtdiaenl', '#frmConsulta2').css({ 'width': '140px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '3');
    $('#cdsinfmg', '#frmConsulta2').css({ 'width': '120px', 'text-align': 'left' }).desabilitaCampo();
    $('#taamaxer', '#frmConsulta2').css({ 'width': '140px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '3');

    $('#flgcmtlc', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#vllimapv', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '18').setMask("DECIMAL", "zzz.zzz.zzz.zz9,99", "", "");
    $('#cdcrdarr', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '8').desabilitaCampo();
    $('#cdagsede', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '8').desabilitaCampo();
    $('#vlmaxcen', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '18').setMask("DECIMAL", "zzz.zzz.zzz.zz9,99", "", "");
    $('#vlmaxleg', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '18').setMask("DECIMAL", "zzz.zzz.zzz.zz9,99", "", "");
    $('#vlmaxutl', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '18').setMask("DECIMAL", "zzz.zzz.zzz.zz9,99", "", "");
    $('#vlcnsscr', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '18').setMask("DECIMAL", "zzz.zzz.zzz.zz9,99", "", "");
    $('#vllimmes', '#frmConsulta3').css({ 'width': '140px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '18').setMask("DECIMAL", "zzz.zzz.zzz.zz9,99", "", "");
    $('#nrctabol', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#cdlcrbol', '#frmConsulta3').css({ 'width': '140px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");

    $('#dsclactr', '#frmConsulta3').css({ 'width': '590px', 'height': '100px', 'float': 'left', 'margin': '3px 0px 3px 3px', 'padding-right': '1px' }).addClass('alpha').attr('maxlength', '412').desabilitaCampo();

    $('#dsclaccb', '#frmConsulta3').css({ 'width': '590px', 'height': '100px', 'float': 'left', 'margin': '3px 0px 3px 3px', 'padding-right': '1px' }).addClass('alpha').attr('maxlength', '355').desabilitaCampo();

    $('#dsdircop', '#frmConsulta3').css({ 'width': '220px', 'text-align': 'left' }).desabilitaCampo();
    $('#nmdireto', '#frmConsulta3').css({ 'width': '420px', 'text-align': 'left' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $('#flgdopgd', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();
    $('#hrproces', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99:99', ':', '');
    $('#hrfinprc', '#frmConsulta3').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99:99', ':', '');
    $('#dsnotifi', '#frmConsulta3').css({ 'width': '420px', 'height': '80px', 'float': 'left', 'margin': '3px 0px 3px 3px', 'padding-right': '1px' }).addClass('alpha').attr('maxlength', '408').desabilitaCampo();

    $('#nrconven', '#frmConsulta4').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();
    $('#nrversao', '#frmConsulta4').css({ 'width': '60px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '3');
    $('#vldataxa', '#frmConsulta4').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
    $('#vltxinss', '#frmConsulta4').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
    $('#flgargps', '#frmConsulta4').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo();


    $('#dtctrdda', '#frmConsulta4').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('data');
    $('#nrctrdda', '#frmConsulta4').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '20').desabilitaCampo();
    $('#idlivdda', '#frmConsulta4').css({ 'width': '140px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '9').desabilitaCampo();
    $('#nrfoldda', '#frmConsulta4').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '7').setMask("INTEGER", "zzz.zzz", "", "");
    $('#dslocdda', '#frmConsulta4').css({ 'width': '360px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '30').desabilitaCampo();
    $('#dsciddda', '#frmConsulta4').css({ 'width': '360px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '30').desabilitaCampo();

    $('#dtregcob', '#frmConsulta4').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('data');
    $('#idregcob', '#frmConsulta4').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '20').desabilitaCampo();
    $('#idlivcob', '#frmConsulta4').css({ 'width': '140px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '9').desabilitaCampo();
    $('#nrfolcob', '#frmConsulta4').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '7').setMask("INTEGER", "zzz.zzz", "", "");
    $('#dsloccob', '#frmConsulta4').css({ 'width': '360px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '30').desabilitaCampo();
    $('#dscidcob', '#frmConsulta4').css({ 'width': '360px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '30').desabilitaCampo();

    $('#dsnomscr', '#frmConsulta5').css({ 'width': '420px', 'text-align': 'left' }).addClass('alpha').attr('maxlength', '40').desabilitaCampo();
    $('#dsemascr', '#frmConsulta5').css({ 'width': '420px', 'text-align': 'left' }).addClass('email').attr('maxlength', '30').desabilitaCampo();
    $('#dstelscr', '#frmConsulta5').css({ 'width': '145px', 'text-align': 'left' }).addClass('alphanum').attr('maxlength', '25').desabilitaCampo();

    $('#cdagesic', '#frmConsulta5').css({ 'width': '80px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '7').setMask("INTEGER", "zzz.zzz", "", "");
    $('#nrctasic', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '10').setMask("INTEGER", "zz.zzz.zzz", "", "");
    $('#cdcrdins', '#frmConsulta5').css({ 'width': '80px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '8').desabilitaCampo();
    $('#vltarsic', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '4').desabilitaCampo();
    $('#vltardrf', '#frmConsulta5').css({ 'width': '60px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '4').desabilitaCampo();
    $('#vltfcxsb', '#frmConsulta5').css({ 'width': '60px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '4').desabilitaCampo();
    $('#vltfcxcb', '#frmConsulta5').css({ 'width': '60px', 'text-align': 'left' }).addClass('porcento_n').attr('maxlength', '4').desabilitaCampo();
    $('#vlrtrfib', '#frmConsulta5').css({ 'width': '60px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '4').desabilitaCampo();
    $('#hrinigps', '#frmConsulta5').css({ 'width': '60px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#hrfimgps', '#frmConsulta5').css({ 'width': '60px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#hrlimsic', '#frmConsulta5').css({ 'width': '60px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');

    $('#qttmpsgr', '#frmConsulta5').css({ 'width': '60px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');

    $('#flgkitbv', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();

    $('#qtdiasus', '#frmConsulta5').css({ 'width': '80px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '9').setMask("INTEGER", "z.zzz.zzz", "", "");
    $('#hriniatr', '#frmConsulta5').css({ 'width': '80px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#hrfimatr', '#frmConsulta5').css({ 'width': '80px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#flgofatr', '#frmConsulta5').css({ 'width': '140px', 'text-align': 'left' }).desabilitaCampo();

    $('#cdcliser', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).addClass('alphanum').attr('maxlength', '10').desabilitaCampo();

    $('#vlmiplco', '#frmConsulta5').css({ 'width': '140px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    $('#vlmidbco', '#frmConsulta5').css({ 'width': '140px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '14').setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");

    $('#cdfingrv', '#frmConsulta5').css({ 'width': '140px', 'text-align': 'right' }).desabilitaCampo().addClass('inteiro').attr('maxlength', '15').setMask("INTEGER", "999999999999999", "", "");
    $('#cdsubgrv', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '3').desabilitaCampo();
    $('#cdloggrv', '#frmConsulta5').css({ 'width': '140px', 'text-align': 'right' }).addClass('alphanum').attr('maxlength', '8').desabilitaCampo();

    $('#flsaqpre', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();

    $('#permaxde', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).addClass('porcento_n').attr('maxlength', '6').desabilitaCampo();
    $('#qtmaxmes', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '3').desabilitaCampo();
    $('#qtmeatel', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).addClass('inteiro').attr('maxlength', '3').desabilitaCampo();
    $('#flrecpct', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'left' }).desabilitaCampo();

    $('#hrinisac', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#hrfimsac', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#hriniouv', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');
    $('#hrfimouv', '#frmConsulta5').css({ 'width': '100px', 'text-align': 'right' }).desabilitaCampo().setMask('STRING', '99:99', ':', '');

    $('#frmConsulta').css({ 'display': 'block' });
    $('#frmConsulta2').css({ 'display': 'none' });
    $('#frmConsulta3').css({ 'display': 'none' });
    $('#frmConsulta4').css({ 'display': 'none' });
    $('#frmConsulta5').css({ 'display': 'none' });
    $('#divBotoesConsulta').css('display', 'block');
    $('#btVoltar', '#divBotoesConsulta').css({ 'display': 'inline' });
    $('#btConcluir', '#divBotoesConsulta').css({ 'display': 'none' });
    $("#btProsseguir", "#divBotoesConsulta").css({ 'display': 'inline' });

    //Define ação para o campo cdcooper
    $("#cdcooper", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nmrescop
    $("#nmrescop", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    // Se pressionar cNrcpfcgc
    $('#nrdocnpj', '#frmConsulta').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).removeClass('campoErro');

            var cpfCnpj = normalizaNumero($('#nrdocnpj', '#frmConsulta').val());

            //if (cpfCnpj.length <= 11) {
            //     cNrcpfcgc.val(mascara(cpfCnpj, '###.###.###-##'));
            // } else {
            $('#nrdocnpj', '#frmConsulta').val(mascara(cpfCnpj, '##.###.###/####-##'));
            // }

            $(this).nextAll('.campo:first').focus();

            return false;

        }


    });

    //Define ação para o campo dtcdcnpj
    $("#dtcdcnpj", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nmextcop
    $("#nmextcop", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dsendcop
    $("#dsendcop", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrendcop
    $("#nrendcop", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dscomple
    $("#dscomple", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nmbairro
    $("#nmbairro", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrcepend
    $("#nrcepend", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nmcidade
    $("#nmcidade", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdufdcop
    $("#cdufdcop", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrcxapst
    $("#nrcxapst", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrtelvoz
    $("#nrtelvoz", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrtelouv
    $("#nrtelouv", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dsendweb
    $("#dsendweb", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrtelura
    $("#nrtelura", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dsdemail
    $("#dsdemail", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrtelfax
    $("#nrtelfax", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dsdempst
    $("#dsdempst", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrtelsac
    $("#nrtelsac", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#nmtitcop", "#frmConsulta").focus();

            return false;
        }

    });

    //Define ação para o campo nmtitcop
    $("#nmtitcop", "#frmConsulta").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    // Se pressionar nrcpftit
    $('#nrcpftit', '#frmConsulta').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).removeClass('campoErro');

            var cpfCnpj = normalizaNumero($('#nrcpftit', '#frmConsulta').val());

            //if (cpfCnpj.length <= 11) {
            //     cNrcpfcgc.val(mascara(cpfCnpj, '###.###.###-##'));
            // } else {
            $('#nrcpftit', '#frmConsulta').val(mascara(cpfCnpj, '###.###.###-##'));
            // }

            $('#btProsseguir', '#divBotoesConsulta').click();

            return false;

        }


    });

    //Define ação para o campo nmctrcop
    $("#nmctrcop", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    // Se pressionar nrcpfctr
    $('#nrcpfctr', '#frmConsulta2').unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB, F1
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 18) {

            $(this).removeClass('campoErro');

            var cpfCnpj = normalizaNumero($('#nrcpfctr', '#frmConsulta2').val());

            //if (cpfCnpj.length <= 11) {
            //     cNrcpfcgc.val(mascara(cpfCnpj, '###.###.###-##'));
            // } else {
            $('#nrcpfctr', '#frmConsulta2').val(mascara(cpfCnpj, '###.###.###-##'));
            // }

            $(this).nextAll('.campo:first').focus();

            return false;

        }


    });

    //Define ação para o campo nrcrcctr
    $("#nrcrcctr", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dsemlctr
    $("#dsemlctr", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrrjunta
    $("#nrrjunta", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dtrjunta
    $("#dtrjunta", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrinsest
    $("#nrinsest", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrinsmun
    $("#nrinsmun", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrlivapl
    $("#nrlivapl", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrlivcap
    $("#nrlivcap", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrlivdpv
    $("#nrlivdpv", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrlivepr
    $("#nrlivepr", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#cdbcoctl", "#frmConsulta2").focus();

            return false;
        }

    });

    //Define ação para o campo cdbcoctl
    $("#cdbcoctl", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdagectl
    $("#cdagectl", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cddigage
    $("#cddigage", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgdsirc
    $("#flgdsirc", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgopstr
    $("#flgopstr", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo iniopstr
    $("#iniopstr", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo fimopstr
    $("#fimopstr", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
    //Define ação para o campo flgoppag
    $("#flgoppag", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
    //Define ação para o campo inioppag
    $("#inioppag", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo fimoppag
    $("#fimoppag", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });


    //Define ação para o campo flgvrbol
    $("#flgvrbol", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
    //Define ação para o campo hhvrbini
    $("#hhvrbini", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hhvrbfim
    $("#hhvrbfim", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdagebcb
    $("#cdagebcb", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            if ($(this).val() != 0) {

                $("#flgcrmag", "#frmConsulta2").habilitaCampo();
                $("#qtdiaenl", "#frmConsulta2").habilitaCampo();
                $("#cdsinfmg", '#frmConsulta2').habilitaCampo();
                $("#taamaxer", "#frmConsulta2").habilitaCampo();
                $("#cdagedbb", "#frmConsulta2").habilitaCampo().focus();
                $("#cdcnvitg", "#frmConsulta2").habilitaCampo();
                $("#nrctabbd", "#frmConsulta2").habilitaCampo();
                $("#nrctaitg", "#frmConsulta2").habilitaCampo();
                $("#nrctacmp", "#frmConsulta2").habilitaCampo();
                $("#flgdsirc", "#frmConsulta2").habilitaCampo();
                $("#cdageitg", "#frmConsulta2").habilitaCampo();
                $("#cdmasitg", "#frmConsulta2").habilitaCampo();
                $("#nrctactl", "#frmConsulta2").habilitaCampo();
                $("#nrctadbb", "#frmConsulta2").habilitaCampo();
                $("#nrdconta", "#frmConsulta2").habilitaCampo();
                $("#flgcrmag", "#frmConsulta2").habilitaCampo();

            } else {

                $("#flgcrmag", "#frmConsulta2").val('0').desabilitaCampo();
                $("#qtdiaenl", "#frmConsulta2").val('0').desabilitaCampo();
                $("#cdsinfmg option[value='0']", '#frmConsulta2').prop('selected', true).desabilitaCampo();
                $("#taamaxer", "#frmConsulta2").val('0 - Não emite').desabilitaCampo();

                $("#cdagedbb", "#frmConsulta2").habilitaCampo().focus();
                $("#cdcnvitg", "#frmConsulta2").habilitaCampo();
                $("#nrctabbd", "#frmConsulta2").habilitaCampo();
                $("#nrctaitg", "#frmConsulta2").habilitaCampo();
                $("#nrctacmp", "#frmConsulta2").habilitaCampo();
                $("#flgdsirc", "#frmConsulta2").habilitaCampo();
                $("#cdageitg", "#frmConsulta2").habilitaCampo();
                $("#cdmasitg", "#frmConsulta2").habilitaCampo();
                $("#nrctactl", "#frmConsulta2").habilitaCampo();
                $("#nrctadbb", "#frmConsulta2").habilitaCampo();
                $("#nrdconta", "#frmConsulta2").habilitaCampo();
                $("#flgcrmag", "#frmConsulta2").habilitaCampo();

            }

            return false;
        }

    });

    //Define ação para o campo cdagedbb
    $("#cdagedbb", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdageitg
    $("#cdageitg", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdcnvitg
    $("#cdcnvitg", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
    //Define ação para o campo cdmasitg
    $("#cdmasitg", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dssigaut
    $("#dssigaut", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrctabbd
    $("#nrctabbd", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
    //Define ação para o campo nrctactl
    $("#nrctactl", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrctaitg
    $("#nrctaitg", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrctadbb
    $("#nrctadbb", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });
    //Define ação para o campo nrctacmp
    $("#nrctacmp", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrdconta
    $("#nrdconta", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgcrmag
    $("#flgcrmag", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            if ($(this).val() != 0) {

                $("#qtdiaenl", "#frmConsulta2").habilitaCampo().focus();
                $("#cdsinfmg", "#frmConsulta2").habilitaCampo();
                $("#taamaxer", '#frmConsulta2').habilitaCampo();

            } else {

                $("#qtdiaenl", "#frmConsulta2").val('0').desabilitaCampo();
                $("#cdsinfmg option[value='0']", '#frmConsulta2').prop('selected', true).desabilitaCampo();
                $("#taamaxer", "#frmConsulta2").val('0 - Não emite').desabilitaCampo();

            }

            return false;
        }

    });


    //Define ação para o campo qtdiaenl
    $("#qtdiaenl", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdsinfmg
    $("#cdsinfmg", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo taamaxer
    $("#taamaxer", "#frmConsulta2").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btProsseguir', '#divBotoesConsulta').click();

            return false;
        }

    });

    //Define ação para o campo flgcmtlc
    $("#flgcmtlc", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {


        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            if ($(this).val() == 1) {

                $("#vllimapv", "#frmConsulta3").val('0').desabilitaCampo();
                $("#cdcrdarr", "#frmConsulta3").focus();

            } else {

                $("#vllimapv", "#frmConsulta3").habilitaCampo().focus();
            }

            return false;
        }

    });

    //Define ação para o campo vllimapv
    $("#vllimapv", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdcrdarr
    $("#cdcrdarr", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdagsede
    $("#cdagsede", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vlmaxcen
    $("#vlmaxcen", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vlmaxleg
    $("#vlmaxleg", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vlmaxutl
    $("#vlmaxutl", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vlcnsscr
    $("#vlcnsscr", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vllimmes
    $("#vllimmes", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrctabol
    $("#nrctabol", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdlcrbol
    $("#cdlcrbol", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#dsclactr", "#frmConsulta3").focus();

            return false;
        }

    });

    //Define ação para o campo dsclactr
    $("#dsclactr", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#dsclaccb", "#frmConsulta3").focus();

            return false;
        }

    });

    //Define ação para o campo dsclaccb
    $("#dsclaccb", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#dsdircop", "#frmConsulta3").focus();

            return false;
        }

    });

    //Define ação para o campo dsdircop
    $("#dsdircop", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nmdireto
    $("#nmdireto", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgdopgd
    $("#flgdopgd", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hrproces
    $("#hrproces", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hrfinprc
    $("#hrfinprc", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dsnotifi
    $("#dsnotifi", "#frmConsulta3").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

    });


    //Define ação para o campo nrconven
    $("#nrconven", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrversao
    $("#nrversao", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vldataxa
    $("#vldataxa", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vltxinss
    $("#vltxinss", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgargps
    $("#flgargps", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#dtctrdda", "#frmConsulta4").focus();

            return false;
        }

    });

    //Define ação para o campo dtctrdda
    $("#dtctrdda", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrctrdda
    $("#nrctrdda", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo idlivdda
    $("#idlivdda", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrfoldda
    $("#nrfoldda", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dslocdda
    $("#dslocdda", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dsciddda
    $("#dsciddda", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#dtregcob", "#frmConsulta4").focus();

            return false;
        }

    });

    //Define ação para o campo dtregcob
    $("#dtregcob", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo idregcob
    $("#idregcob", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo idlivcob
    $("#idlivcob", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrfolcob
    $("#nrfolcob", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dsloccob
    $("#dsloccob", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dscidcob
    $("#dscidcob", "#frmConsulta4").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btProsseguir', '#divBotoesConsulta').click();

            return false;
        }

    });


    //Define ação para o campo dsnomscr
    $("#dsnomscr", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });


    //Define ação para o campo dsemascr
    $("#dsemascr", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo dstelscr
    $("#dstelscr", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#cdagesic", "#frmConsulta5").focus();

            return false;
        }

    });

    //Define ação para o campo cdagesic
    $("#cdagesic", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo nrctasic
    $("#nrctasic", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdcrdins
    $("#cdcrdins", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vltarsic
    $("#vltarsic", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vltardrf
    $("#vltardrf", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vltfcxsb
    $("#vltfcxsb", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vltfcxcb
    $("#vltfcxcb", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }


    });


    //Define ação para o campo vlrtrfib
    $("#vlrtrfib", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hrinigps
    $("#hrinigps", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hrfimgps
    $("#hrfimgps", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hrlimsic
    $("#hrlimsic", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#qttmpsgr", "#frmConsulta5").focus();

            return false;
        }

    });

    //Define ação para o campo qttmpsgr
    $("#qttmpsgr", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#flgkitbv", "#frmConsulta5").focus();

            return false;
        }

    });
    //Define ação para o campo flgkitbv
    $("#flgkitbv", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#qtdiasus", "#frmConsulta5").focus();

            return false;
        }

    });

    //Define ação para o campo qtdiasus
    $("#qtdiasus", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hriniatr
    $("#hriniatr", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hrfimatr
    $("#hrfimatr", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flgofatr
    $("#flgofatr", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#cdcliser", "#frmConsulta5").focus();

            return false;
        }

    });

    //Define ação para o campo cdcliser
    $("#cdcliser", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#vlmiplco", "#frmConsulta5").focus();

            return false;
        }

    });

    //Define ação para o campo vlmiplco
    $("#vlmiplco", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo vlmidbco
    $("#vlmidbco", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#cdfingrv", "#frmConsulta5").focus();

            return false;
        }

    });

    //Define ação para o campo cdfingrv
    $("#cdfingrv", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdsubgrv
    $("#cdsubgrv", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo cdloggrv
    $("#cdloggrv", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#flsaqpre", "#frmConsulta5").focus();

            return false;
        }

    });

    //Define ação para o campo flsaqpre
    $("#flsaqpre", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#permaxde", "#frmConsulta5").focus();

            return false;
        }

    });

    //Define ação para o campo permaxde
    $("#permaxde", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo qtmaxmes
    $("#qtmaxmes", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo flrecpct
    $("#flrecpct", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#qtmeatel", "#frmConsulta5").focus();

            return false;
        }

    });

    //Define ação para o campo qtmeatel
    $("#qtmeatel", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $("#hrinisac", "#frmConsulta5").focus();

            return false;
        }

    });

    //Define ação para o campo hrinisac
    $("#hrinisac", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hrfimsac
    $("#hrfimsac", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hriniouv
    $("#hriniouv", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $(this).nextAll('.campo:first').focus();

            return false;
        }

    });

    //Define ação para o campo hrfimouv
    $("#hrfimouv", "#frmConsulta5").unbind('keypress').bind('keypress', function (e) {

        if (divError.css('display') == 'block') { return false; }

        $('input,select').removeClass('campoErro');

        // Se é a tecla ENTER, TAB
        if (e.keyCode == 13 || e.keyCode == 9) {

            $('#btConcluir','#divBotoesConsulta').click();

            return false;
        }

    });


    if ($('#cddopcao','#frmCab').val() == 'A'){

        if(cddepart != 20) {

            $("#qttmpsgr", "#frmConsulta5").desabilitaCampo();

        } else {

            $("#qttmpsgr", "#frmConsulta5").habilitaCampo();

        }

    }

    //Define ação para CLICK no botão de Concluir
    $("#btConcluir", "#divBotoesConsulta").unbind('click').bind('click', function () {

        showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'alterarCooperativa();', '$(\'#btVoltar\',\'#divBotoesConsulta\').focus();', 'sim.gif', 'nao.gif');
        return false;
    });

    //Define ação para CLICK no botão de Prosseguir
    $("#btProsseguir", "#divBotoesConsulta").unbind('click').bind('click', function () {

        controlaDisplayForm('1');
        return false;

    });

    //Define ação para CLICK no botão de Voltar
    $("#btVoltar", "#divBotoesConsulta").unbind('click').bind('click', function () {

        controlaDisplayForm('2');

        return false;

    });

    layoutPadrao();

    if ($('#cddopcao', '#frmCab').val() == 'A') {

        $('input,select,textarea', '#divTabela').habilitaCampo();
        $('#cdcooper', '#frmConsulta').desabilitaCampo();
        $('#cddigage', '#frmConsulta2').desabilitaCampo();
        $('#dssigaut', '#frmConsulta2').desabilitaCampo();
        $('#flgopstr', '#frmConsulta2').desabilitaCampo();
        $('#iniopstr', '#frmConsulta2').desabilitaCampo();
        $('#fimopstr', '#frmConsulta2').desabilitaCampo();
        $('#flgoppag', '#frmConsulta2').desabilitaCampo();
        $('#inioppag', '#frmConsulta2').desabilitaCampo();
        $('#fimoppag', '#frmConsulta2').desabilitaCampo();
        $('#flgvrbol', '#frmConsulta2').desabilitaCampo();
        $('#hhvrbini', '#frmConsulta2').desabilitaCampo();
        $('#hhvrbfim', '#frmConsulta2').desabilitaCampo();
        $('#nmrescop', '#frmConsulta').focus();

    } else {

        $("#btProsseguir", "#divBotoesConsulta").focus();

    }

    return false;

}



function controlaPesquisa(valor) {

    switch (valor) {

        case '1':
            controlaPesquisaLinha();
            break;

        case '2':
            controlaPesquisaModalidade();
            break;

        case '3':
            controlaPesquisaSubModalidade();
            break;

        case '4':
            controlaPesquisaHistorico();
            break;

        case '5':
            controlaPesquisaFinalidadeEmpr();
            break;

    }

}


// Consulta Histórico
function controlaPesquisaHistorico() {

    // Se esta desabilitado o campo
    if ($("#cdhistor", "#frmConsulta").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Hist;cdhistor;80px;S;0;|Histórico;dshistor;200px;S;|Indicador;inautori;80px;S;0;N;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdhistor;20%;right|Histórico;dshistor;80%;left';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "CONSHISTORICOS", "Histórico", "30", filtros, colunas, '', '$(\'#cdhistor\',\'#frmConsulta\').focus();', 'frmConsulta');

    $("#divCabecalhoPesquisa > table").css("width", "500px");
    $("#divResultadoPesquisa > table").css("width", "500px");
    $("#divCabecalhoPesquisa").css("width", "500px");
    $("#divResultadoPesquisa").css("width", "500px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}

// Consulta Finalidades de empréstimo
function controlaPesquisaFinalidadeEmpr() {

    // Se esta desabilitado o campo
    if ($("#cdfinemp", "#frmConsulta").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Finalidade do Empr.;cdfinemp;30px;S;0|Descri&ccedil&atildeo;dsfinemp;200px;S;|;flgstfin;;;3;N|;tpfinali;;;;N';

    //Campos que serão exibidos na tela
    var colunas = 'C&oacutedigo;cdfinemp;20%;right|Finalidade;dsfinemp;80%;left|Flag;flgstfin;0%;left;;N|Tipo;tpfinali;0%;left;;N';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "BUSCAFINEMPR", "Finalidade do Empr&eacutestimo", "30", filtros, colunas, '', '$(\'#cdfinemp\',\'#frmConsulta\').focus();', 'frmConsulta');

    $("#divCabecalhoPesquisa > table").css("width", "500px");
    $("#divResultadoPesquisa > table").css("width", "500px");
    $("#divCabecalhoPesquisa").css("width", "500px");
    $("#divResultadoPesquisa").css("width", "500px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}

function controlaPesquisaLinha() {

    // Se esta desabilitado o campo
    if ($("#cdlcremp", "#frmFiltro").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input', '#frmFiltro').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    var nrconven = normalizaNumero($('#cdlcremp', '#frmFiltro').val());

    //Definição dos filtros
    var filtros = "Linhas;cdlcremp;120px;S;;;|Descrição;dslcremp;120px;S;;descricao|;flgstlcr;;;0;N";

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdlcremp;10%;right|Descrição;dslcremp;50%;left|Situação;flgstlcr;20%;left;|Garantia;tpctrato;20%;center';

    //Exibir a pesquisa
    mostraPesquisa("zoom0001", "BUSCALINHASCREDITO", "Linhas de Cr&eacute;dito", "30", filtros, colunas, '', '$(\'#cdlcremp\',\'#frmFiltro\').focus();', 'frmFiltro');

    $("#divCabecalhoPesquisa > table").css("width", "600px");
    $("#divResultadoPesquisa > table").css("width", "600px");
    $("#divCabecalhoPesquisa").css("width", "600px");
    $("#divResultadoPesquisa").css("width", "600px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}


function controlaPesquisaModalidade() {

    // Se esta desabilitado o campo
    if ($("#cdmodali", "#frmConsulta").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = "Linhas;cdmodali;20%;S;0;N;|Descrição;dsmodali;50%;S;;N;";

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdmodali;20%;center|Descrição;dsmodali;50%;left';

    //Exibir a pesquisa
    mostraPesquisa("TELA_LCREDI", "CONSMOD", "Modalidades", "30", filtros, colunas, '', '$(\'#cdmodali\',\'#frmConsulta\').val();', 'frmConsulta');

    $("#divCabecalhoPesquisa > table").css("width", "600px");
    $("#divResultadoPesquisa > table").css("width", "600px");
    $("#divCabecalhoPesquisa").css("width", "600px");
    $("#divResultadoPesquisa").css("width", "600px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}


function controlaPesquisaSubModalidade() {

    // Se esta desabilitado o campo
    if ($("#cdsubmod", "#frmConsulta").prop("disabled") == true) {
        return;
    }

    /* Remove foco de erro */
    $('input,select', '#frmConsulta').removeClass('campoErro');

    var bo, procedure, titulo, qtReg, filtrosPesq, colunas;

    //Definição dos filtros
    var filtros = 'Cód. Submodalidade;cdsubmod;20%;S;;;codigo;|Descrição;dssubmod;50%;S;;N;|Cód. Modalidade;cdmodali;20%;N;' + $('#cdmodali', '#frmConsulta').val() + ';S;codigo;';

    //Campos que serão exibidos na tela
    var colunas = 'Código;cdsubmod;20%;center|Descrição;dssubmod;50%;left';

    //Exibir a pesquisa
    mostraPesquisa("TELA_LCREDI", "CONSSUBMOD", "Submodalidades", "30", filtros, colunas, '', '$(\'#cdsubmod\',\'#frmConsulta\').val();', 'frmConsulta');

    $("#divCabecalhoPesquisa > table").css("width", "600px");
    $("#divResultadoPesquisa > table").css("width", "600px");
    $("#divCabecalhoPesquisa").css("width", "600px");
    $("#divResultadoPesquisa").css("width", "600px");
    $('#divPesquisa').centralizaRotinaH();

    return false;

}

function controlaVoltar(ope,tpconsul) {

    switch (ope) {

        case '1':

            estadoInicial();

        break;

        case '2':

            //Limpa formulario
            $('input[type="text"]', '#frmFiltro').limpaFormulario();
            $('#divTabela').html('').css('display', 'none');
            formataFiltro();

        break;

        case '3':

            formataFiltro();

        break;

        case '4':

            if (tpconsul == 'C') {

                $('#nrctrpro', '#frmFiltro').focus();

            } else {
                $('#nrgravam', '#frmFiltro').focus();
            }

            fechaRotina($('#divRotina'));
            $('#divRotina').html('');

        break;

    }

    return false;

}



function consultaCooperativa() {

    var cddopcao = $("#cddopcao", "#frmCab").val();

    showMsgAguardo("Aguarde, consultando cooperativa ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcop/consulta_cooperativa.php",
        data: {
            cddopcao: cddopcao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTabela').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }

    });

    return false;

}


function alterarCooperativa() {

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var nmrescop = $("#nmrescop", "#frmConsulta").val();
    var nrdocnpj = normalizaNumero($("#nrdocnpj", "#frmConsulta").val());
    var nmextcop = $("#nmextcop", "#frmConsulta").val();
    var dtcdcnpj = $("#dtcdcnpj", "#frmConsulta").val();
    var dsendcop = $("#dsendcop", "#frmConsulta").val();
    var nrendcop = normalizaNumero($("#nrendcop", "#frmConsulta").val());
    var dscomple = $("#dscomple", "#frmConsulta").val();
    var nmbairro = $("#nmbairro", "#frmConsulta").val();
    var nrcepend = normalizaNumero($("#nrcepend", "#frmConsulta").val());
    var nmcidade = $("#nmcidade", "#frmConsulta").val();
    var cdufdcop = $("#cdufdcop", "#frmConsulta").val();
    var nrcxapst = normalizaNumero($("#nrcxapst", "#frmConsulta").val());
    var nrtelvoz = $("#nrtelvoz", "#frmConsulta").val();
    var nrtelouv = $("#nrtelouv", "#frmConsulta").val();
    var dsendweb = $("#dsendweb", "#frmConsulta").val();
    var nrtelura = $("#nrtelura", "#frmConsulta").val();
    var dsdemail = $("#dsdemail", "#frmConsulta").val();
    var nrtelfax = $("#nrtelfax", "#frmConsulta").val();
    var dsdempst = $("#dsdempst", "#frmConsulta").val();
    var nrtelsac = $("#nrtelsac", "#frmConsulta").val();
    var nmtitcop = $("#nmtitcop", "#frmConsulta").val();
    var nrcpftit = normalizaNumero($("#nrcpftit", "#frmConsulta").val());

    var nmctrcop = $("#nmctrcop", "#frmConsulta2").val();
    var nrcpfctr = normalizaNumero($("#nrcpfctr", "#frmConsulta2").val());
    var nrcrcctr = $("#nrcrcctr", "#frmConsulta2").val();
    var dsemlctr = $("#dsemlctr", "#frmConsulta2").val();
    var nrrjunta = normalizaNumero($("#nrrjunta", "#frmConsulta2").val());
    var dtrjunta = $("#dtrjunta", "#frmConsulta2").val();
    var nrinsest = normalizaNumero($("#nrinsest", "#frmConsulta2").val());
    var nrinsmun = normalizaNumero($("#nrinsmun", "#frmConsulta2").val());
    var nrlivapl = $("#nrlivapl", "#frmConsulta2").val();
    var nrlivcap = $("#nrlivcap", "#frmConsulta2").val();
    var nrlivdpv = $("#nrlivdpv", "#frmConsulta2").val();
    var nrlivepr = $("#nrlivepr", "#frmConsulta2").val();
    var cdbcoctl = $("#cdbcoctl", "#frmConsulta2").val();
    var cdagebcb = normalizaNumero($("#cdagebcb", "#frmConsulta2").val());
    var cdagedbb = normalizaNumero($("#cdagedbb", "#frmConsulta2").val());
    var cdageitg = $("#cdageitg", "#frmConsulta2").val();
    var cdcnvitg = $("#cdcnvitg", "#frmConsulta2").val();
    var cdmasitg = $("#cdmasitg", "#frmConsulta2").val();
    var nrctabbd = normalizaNumero($("#nrctabbd", "#frmConsulta2").val());
    var nrctactl = normalizaNumero($("#nrctactl", "#frmConsulta2").val());
    var nrctaitg = normalizaNumero($("#nrctaitg", "#frmConsulta2").val());
    var nrctadbb = normalizaNumero($("#nrctadbb", "#frmConsulta2").val());
    var nrctacmp = normalizaNumero($("#nrctacmp", "#frmConsulta2").val());
    var nrdconta = normalizaNumero($("#nrdconta", "#frmConsulta2").val());
    var flgdsirc = $("#flgdsirc", "#frmConsulta2").val();
    var flgcrmag = $("#flgcrmag", "#frmConsulta2").val();
    var cdagectl = normalizaNumero($("#cdagectl", "#frmConsulta2").val());
    var qtdiaenl = $("#qtdiaenl", "#frmConsulta2").val();
    var cdsinfmg = $("#cdsinfmg", "#frmConsulta2").val();
    var taamaxer = $("#taamaxer", "#frmConsulta2").val();

    var cdcrdarr = $("#cdcrdarr", "#frmConsulta3").val();
    var cdagsede = $("#cdagsede", "#frmConsulta3").val();
    var nrctabol = normalizaNumero($("#nrctabol", "#frmConsulta3").val());
    var cdlcrbol = $("#cdlcrbol", "#frmConsulta3").val();
    var flgcmtlc = $("#flgcmtlc", "#frmConsulta3").val();
    var hrproces = $("#hrproces", "#frmConsulta3").val();
    var hrfinprc = $("#hrfinprc", "#frmConsulta3").val();
    var dsdircop = $("#dsdircop", "#frmConsulta3").val();
    var dsnotifi = $("#dsnotifi", "#frmConsulta3").val();
    var nmdireto = $("#nmdireto", "#frmConsulta3").val();
    var flgdopgd = $("#flgdopgd", "#frmConsulta3").val();
    var dsclactr = $("#dsclactr", "#frmConsulta3").val();
    var dsclaccb = $("#dsclaccb", "#frmConsulta3").val();
    var vllimapv = isNaN(parseFloat($('#vllimapv', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vllimapv', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."));
    var vlmaxcen = isNaN(parseFloat($('#vlmaxcen', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmaxcen', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."));
    var vlmaxleg = isNaN(parseFloat($('#vlmaxleg', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmaxleg', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."));
    var vlmaxutl = isNaN(parseFloat($('#vlmaxutl', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmaxutl', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."));
    var vlcnsscr = isNaN(parseFloat($('#vlcnsscr', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlcnsscr', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."));
    var vllimmes = isNaN(parseFloat($('#vllimmes', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vllimmes', '#frmConsulta3').val().replace(/\./g, "").replace(/\,/g, "."));

    var dtctrdda = $("#dtctrdda", "#frmConsulta4").val();
    var nrctrdda = $("#nrctrdda", "#frmConsulta4").val();
    var idlivdda = $("#idlivdda", "#frmConsulta4").val();
    var nrfoldda = $("#nrfoldda", "#frmConsulta4").val();
    var dslocdda = $("#dslocdda", "#frmConsulta4").val();
    var dsciddda = $("#dsciddda", "#frmConsulta4").val();
    var dtregcob = $("#dtregcob", "#frmConsulta4").val();
    var idregcob = $("#idregcob", "#frmConsulta4").val();
    var idlivcob = $("#idlivcob", "#frmConsulta4").val();
    var nrfolcob = $("#nrfolcob", "#frmConsulta4").val();
    var dsloccob = $("#dsloccob", "#frmConsulta4").val();
    var dscidcob = $("#dscidcob", "#frmConsulta4").val();
    var vltxinss = isNaN(parseFloat($('#vltxinss', '#frmConsulta4').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltxinss', '#frmConsulta4').val().replace(/\./g, "").replace(/\,/g, "."));
    var flgargps = $("#flgargps", "#frmConsulta4").val();
    var vldataxa = isNaN(parseFloat($('#vldataxa', '#frmConsulta4').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vldataxa', '#frmConsulta4').val().replace(/\./g, "").replace(/\,/g, "."));
    var nrversao = $("#nrversao", "#frmConsulta4").val();
    var nrconven = $("#nrconven", "#frmConsulta4").val();

    var dstelscr = $("#dstelscr", "#frmConsulta5").val();
    var qttmpsgr = $("#qttmpsgr", "#frmConsulta5").val();
    var hrinisac = $("#hrinisac", "#frmConsulta5").val();
    var hrfimsac = $("#hrfimsac", "#frmConsulta5").val();
    var hriniouv = $("#hriniouv", "#frmConsulta5").val();
    var hrfimouv = $("#hrfimouv", "#frmConsulta5").val();
    var vltfcxsb = isNaN(parseFloat($('#vltfcxsb', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltfcxsb', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."));
    var vltfcxcb = isNaN(parseFloat($('#vltfcxcb', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltfcxcb', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."));
    var vlrtrfib = isNaN(parseFloat($('#vlrtrfib', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlrtrfib', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."));
    var flrecpct = $("#flrecpct", "#frmConsulta5").val();
    var flsaqpre = $("#flsaqpre", "#frmConsulta5").val();
    var qtmaxmes = $("#qtmaxmes", "#frmConsulta5").val();
    var qtmeatel = $("#qtmeatel", "#frmConsulta5").val();
    var permaxde = isNaN(parseFloat($('#permaxde', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#permaxde', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."));
    var cdloggrv = $("#cdloggrv", "#frmConsulta5").val();
    var flgofatr = $("#flgofatr", "#frmConsulta5").val();
    var qtdiasus = $("#qtdiasus", "#frmConsulta5").val();
    var cdcliser = $("#cdcliser", "#frmConsulta5").val();
    var vlmiplco = isNaN(parseFloat($('#vlmiplco', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmiplco', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."));
    var vlmidbco = isNaN(parseFloat($('#vlmidbco', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vlmidbco', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."));
    var cdfingrv = $("#cdfingrv", "#frmConsulta5").val();
    var cdsubgrv = $("#cdsubgrv", "#frmConsulta5").val();
    var hriniatr = $("#hriniatr", "#frmConsulta5").val();
    var hrfimatr = $("#hrfimatr", "#frmConsulta5").val();
    var flgkitbv = $("#flgkitbv", "#frmConsulta5").val();
    var hrinigps = $("#hrinigps", "#frmConsulta5").val();
    var hrfimgps = $("#hrfimgps", "#frmConsulta5").val();
    var hrlimsic = $("#hrlimsic", "#frmConsulta5").val();
    var dsnomscr = $("#dsnomscr", "#frmConsulta5").val();
    var dsemascr = $("#dsemascr", "#frmConsulta5").val();
    var cdagesic = normalizaNumero($("#cdagesic", "#frmConsulta5").val());
    var nrctasic = normalizaNumero($("#nrctasic", "#frmConsulta5").val());
    var cdcrdins = $("#cdcrdins", "#frmConsulta5").val();
    var vltarsic = isNaN(parseFloat($('#vltarsic', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltarsic', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."));
    var vltardrf = isNaN(parseFloat($('#vltardrf', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."))) ? 0 : parseFloat($('#vltardrf', '#frmConsulta5').val().replace(/\./g, "").replace(/\,/g, "."));
    var qttmpsgr = $("#qttmpsgr", "#frmConsulta5").val();

    showMsgAguardo("Aguarde, alterando cooperativa ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcop/alterar_cooperativa.php",
        data: {
            cddopcao: cddopcao,
            nmrescop: nmrescop,
            nrdocnpj: nrdocnpj,
            nmextcop: nmextcop,
            dtcdcnpj: dtcdcnpj,
            dsendcop: dsendcop,
            nrendcop: nrendcop,
            dscomple: dscomple,
            nmbairro: nmbairro,
            nrcepend: nrcepend,
            nmcidade: nmcidade,
            cdufdcop: cdufdcop,
            nrcxapst: nrcxapst,
            nrtelvoz: nrtelvoz,
            nrtelouv: nrtelouv,
            dsendweb: dsendweb,
            nrtelura: nrtelura,
            dsdemail: dsdemail,
            nrtelfax: nrtelfax,
            dsdempst: dsdempst,
            nrtelsac: nrtelsac,
            nmtitcop: nmtitcop,
            nrcpftit: nrcpftit,
            nmctrcop: nmctrcop,
            nrcpfctr: nrcpfctr,
            nrcrcctr: nrcrcctr,
            dsemlctr: dsemlctr,
            nrrjunta: nrrjunta,
            dtrjunta: dtrjunta,
            nrinsest: nrinsest,
            nrinsmun: nrinsmun,
            nrlivapl: nrlivapl,
            nrlivcap: nrlivcap,
            nrlivdpv: nrlivdpv,
            nrlivepr: nrlivepr,
            cdbcoctl: cdbcoctl,
            cdagebcb: cdagebcb,
            cdagedbb: cdagedbb,
            cdageitg: cdageitg,
            cdcnvitg: cdcnvitg,
            cdmasitg: cdmasitg,
            nrctabbd: nrctabbd,
            nrctactl: nrctactl,
            nrctaitg: nrctaitg,
            nrctadbb: nrctadbb,
            nrctacmp: nrctacmp,
            nrdconta: nrdconta,
            flgdsirc: flgdsirc,
            flgcrmag: flgcrmag,
            cdagectl: cdagectl,
            dstelscr: dstelscr,
            cdcrdarr: cdcrdarr,
            cdagsede: cdagsede,
            nrctabol: nrctabol,
            cdlcrbol: cdlcrbol,
            vltxinss: vltxinss,
            flgargps: flgargps,
            vldataxa: vldataxa,
            nrversao: nrversao,
            nrconven: nrconven,
            qttmpsgr: qttmpsgr,
            hrinisac: hrinisac,
            hrfimsac: hrfimsac,
            hriniouv: hriniouv,
            hrfimouv: hrfimouv,
            vltfcxsb: vltfcxsb,
            vltfcxcb: vltfcxcb,
            vlrtrfib: vlrtrfib,
            flrecpct: flrecpct,
            flsaqpre: flsaqpre,
            flgcmtlc: flgcmtlc,
            qtmaxmes: qtmaxmes,
            qtmeatel: qtmeatel,
            permaxde: permaxde,
            cdloggrv: cdloggrv,
            flgofatr: flgofatr,
            qtdiasus: qtdiasus,
            cdcliser: cdcliser,
            vlmiplco: vlmiplco,
            vlmidbco: vlmidbco,
            cdfingrv: cdfingrv,
            cdsubgrv: cdsubgrv,
            hriniatr: hriniatr,
            hrfimatr: hrfimatr,
            flgkitbv: flgkitbv,
            hrinigps: hrinigps,
            hrfimgps: hrfimgps,
            hrlimsic: hrlimsic,
            dtctrdda: dtctrdda,
            nrctrdda: nrctrdda,
            idlivdda: idlivdda,
            nrfoldda: nrfoldda,
            dslocdda: dslocdda,
            dsciddda: dsciddda,
            dtregcob: dtregcob,
            idregcob: idregcob,
            idlivcob: idlivcob,
            nrfolcob: nrfolcob,
            dsloccob: dsloccob,
            dscidcob: dscidcob,
            dsnomscr: dsnomscr,
            dsemascr: dsemascr,
            cdagesic: cdagesic,
            nrctasic: nrctasic,
            cdcrdins: cdcrdins,
            vltarsic: vltarsic,
            vltardrf: vltardrf,
            hrproces: hrproces,
            hrfinprc: hrfinprc,
            dsdircop: dsdircop,
            dsnotifi: dsnotifi,
            nmdireto: nmdireto,
            flgdopgd: flgdopgd,
            dsclactr: dsclactr,
            dsclaccb: dsclaccb,
            vlmaxcen: vlmaxcen,
            vlmaxleg: vlmaxleg,
            vlmaxutl: vlmaxutl,
            vlcnsscr: vlcnsscr,
            vllimmes: vllimmes,
            qtdiaenl: qtdiaenl,
            cdsinfmg: cdsinfmg,
            taamaxer: taamaxer,
            vllimapv: vllimapv,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'blockBackground(parseInt($("#divRotina").css("z-index")));$("#orgbenef","#frmTrocaDomicilio").focus();');
            }
        }

    });

    return false;

}


function consultaMunicipios(nriniseq, nrregist) {

    var cddopcao = $("#cddopcao", "#frmCab").val();

    showMsgAguardo("Aguarde, consultando municípios ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcop/consulta_municipios.php",
        data: {
            cddopcao: cddopcao,
            nriniseq: nriniseq,
            nrregist: nrregist,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            if (response.indexOf('showError("error"') == -1 && response.indexOf('XML error:') == -1 && response.indexOf('#frmErro') == -1) {
                try {

                    $('#divTabela').html(response);
                    return false;
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            } else {
                try {

                    eval(response);
                } catch (error) {

                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "estadoInicial();");
                }
            }
        }

    });

    return false;

}


function incluirMunicipios(tpoperac) {

    var cddopcao = $("#cddopcao", "#frmCab").val();
    var dscidade = $("#dscidade", "#frmIncluir").val();
    var cdestado = $("#cdestado", "#frmIncluir").val();

    showMsgAguardo("Aguarde, incluindo município ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcop/manter_municipios.php",
        data: {
            cddopcao: cddopcao,
            tpoperac: tpoperac,
            dscidade: dscidade,
            cdestado: cdestado,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'blockBackground(parseInt($("#divRotina").css("z-index")));$("#dscidade","#frmIncluir").focus();');
            }
        }

    });

    return false;

}

function excluirMunicipios(cdcidade, tpoperac) {

    var cddopcao = $("#cddopcao", "#frmCab").val();

    showMsgAguardo("Aguarde, excluindo município ...");

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/cadcop/manter_municipios.php",
        data: {
            cddopcao: cddopcao,
            cdcidade: cdcidade,
            tpoperac: tpoperac,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "estadoInicial();");
        },
        success: function (response) {

            hideMsgAguardo();

            try {
                eval(response);
            } catch (error) {
                showError('error', 'N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', '$("#btVoltar","#divBotoesMunicipios").focus();');
            }
        }

    });

    return false;

}



function formataTabelaMunicipios() {

    var divRegistro = $('div.divRegistros', '#divTabela');
    var tabela = $('table', divRegistro);
    var linha = $('table > tbody > tr', divRegistro);

    divRegistro.css({ 'height': '250px' });
    $('#divRegistrosRodape', '#divTabela').formataRodapePesquisa();

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    arrayLargura[0] = '450px';

    var arrayAlinha = new Array();
    arrayAlinha[0] = 'left';
    arrayAlinha[1] = 'center';

    tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha);

    $('table > tbody > tr', divRegistro).each(function (i) {

        if ($(this).hasClass('corSelecao')) {

            selecionaMunicipio($(this));

        }

    });

    //seleciona o lancamento que é clicado
    $('table > tbody > tr', divRegistro).click(function () {

        selecionaMunicipio($(this));
    });

    return false;

}

function selecionaMunicipio(tr) {

    var cdcidade = $('#cdcidade', tr).val();

    //Define ação para CLICK no botão de Excluir
    $("#btExcluir", "#divBotoesMunicipios").unbind('click').bind('click', function () {

        showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluirMunicipios(' + cdcidade + ', \'E\');', '$(\'#btVoltar\',\'#divBotoesMunicipios\').focus();', 'sim.gif', 'nao.gif');


    });

    //Define ação para CLICK no botão de Excluir
    $("#btIncluir", "#divBotoesMunicipios").unbind('click').bind('click', function () {

        exibeRotina($('#divRotina'));
        formataFormularioIncluir();


    });


}

function controlaFoco(nmdcampo) {

    var parentElement = $('#' + nmdcampo).parent().parent().attr('id');

    $("fieldset", "#divTabela").each(function () {

        if ($(this).parent().attr('id')!= parentElement) {

            $(this).parent().css('display', 'none');

        } else {

            $(this).parent().css('display', 'block');

            focaCampoErro(nmdcampo, parentElement,true);

            if ($(this).attr('id') == $("#divTabela").find("fieldset:last").attr('id')) {

                 $("#btProsseguir", "#divBotoesConsulta").css({ 'display': 'none' });
                 $('#btConcluir', '#divBotoesConsulta').css({ 'display': 'inline' });

             }else{

                 $("#btProsseguir", "#divBotoesConsulta").css({ 'display': 'inline' });
                 $('#btConcluir', '#divBotoesConsulta').css({ 'display': 'none' });

             }

        }

    });

    return false;

}

function controlaDisplayForm(tipo) {

    //Controla prosseguir
    if (tipo == '1') {

        var formVisivel = $('form:visible', '#divTabela').attr('id');

        $("form", "#divTabela").each(function () {

            if ($(this).attr('id') == formVisivel) {

                if ($("#divTabela").find("form:last").attr('id') == $(this).next().attr('id')) {

                    ($('#cddopcao', '#frmCab').val() == 'A') ? $('#btConcluir', '#divBotoesConsulta').css({ 'display': 'inline' }) : $('#btConcluir', '#divBotoesConsulta').css({ 'display': 'none' });

                    $("#btProsseguir", "#divBotoesConsulta").css({ 'display': 'none' });
                    $(this).css('display', 'none');
                    $(this).next().css('display', 'block');
                    $(this).next().find(".campo:first").focus();

                } else {

                    $(this).css('display', 'none');
                    $(this).next().css('display', 'block');
                    $(this).next().find(".campo:first").focus();

                    return false;
                }

            }

        });

    //Controla voltar
    }else if(tipo == '2'){

        var formVisivel = $('form:visible', '#divTabela').attr('id');

        $("form", "#divTabela").each(function () {

            if ($("#divTabela").find("form:first").attr('id') == $('form:visible', '#divTabela').attr('id')) {

                controlaVoltar('1');

                return false;

            }

            if ($(this).attr('id') == $('#' + formVisivel,'#divTabela' ).prev().attr('id')) {

                $('#btConcluir', '#divBotoesConsulta').css({ 'display': 'none' });
                $("#btProsseguir", "#divBotoesConsulta").css({ 'display': 'inline' });
                $(this).css('display', 'block');
                $(this).nextAll('.campo:first').focus();
                $('#' + formVisivel, '#divTabela').css('display', 'none');
                $(this).find(".campo:first").focus();

                return false;

            }

        });

    }

    return false;

}

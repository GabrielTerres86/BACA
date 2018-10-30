$(document).ready(function() {	
	
	estadoInicial();
		
});

function estadoInicial(){
	formataCabecalho();

	$('#cddopcao', '#frmCab').habilitaCampo().focus().val('C');
	$('#divBotoes').css({ 'display': 'none' });
    $('#frmFiltro').css('display', 'none');
    $('#divTabela').html('').css('display','none');
	$('#frmCons').css({'display':'none'});
}

function formataCabecalho() {

    // rotulo
    $('label[for="cddopcao"]', "#frmCab").addClass("rotulo").css({ "width": "45px" });
    // campo
    $("#cddopcao", "#frmCab").css("width", "562px").habilitaCampo();

    $('#divTela').css({ 'display': 'inline' }).fadeTo(0, 0.1);
    removeOpacidade('divTela');
    $('#frmCab').css({ 'display': 'block' });
    highlightObjFocus($('#frmCab'));

	
    $('input[type="text"],select', '#frmCab').limpaFormulario().removeClass('campoErro');

    //Define ação para ENTER e TAB no campo Opção
    $("#cddopcao", "#frmCab").unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $("#btnOK", "#frmCab").trigger('click');
        }
    });

    //Define ação para CLICK no botão de OK
    $("#btnOK", "#frmCab").unbind('click').bind('click', function () {
		// Se esta desabilitado o campo 
        if ($("#cddopcao", "#frmCab").prop("disabled") == true) {
            return false;
        }
		montaTab();
		return false;
    });

    layoutPadrao();
 	
    return false;
}

function refreshCarga(){
    $("#btnOK", "#frmCab").trigger('click');
    fechaRotina($('#divRotina'));
}

function montaTab(){    
    showMsgAguardo("Aguarde ...");
    var cddopcao = $('#cddopcao', '#frmCab').val();

    //Requisição para montar o form correspondente a opção escolhida
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/score/monta_tab.php",
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
                    $('#divTabela').html(response).css({ 'display': 'block' });
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

function formatarTabelaCarga(){
    $('#divTabela').css({ 'width': '760px' });
    $("#cddopcao", "#frmCab").css("width", "670px");
    //$('#fsetFiltro').css({ 'padding': '0 10px 10px 195px' });
    var divRegistro = $('div.divRegistros', '#divCarga');
    divRegistro.css({'padding-bottom':'1px'}); // 370px
    
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    var arrayAlinha = new Array();
    
    arrayLargura[0] = '47px';   //Codigo
    arrayLargura[1] = '298px';   //Modelo Score
    arrayLargura[2] = '79px';  //Data Base
    arrayLargura[3] = '80px';   //Quantidade
    arrayLargura[4] = '78px';   //Quantidade Fisica
    arrayLargura[5] = '78px';   //Quantidade Juridica
    arrayLargura[6] = '14px'; // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem
    
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    initBotoesTabelaCarga();
}

function formatarTabelaHistorico(){
    $('#divTabela').css({ 'width': '1051px' });
    $("#cddopcao", "#frmCab").css("width", "962px");
    //$('#fsetFiltro').css({ 'padding': '0 10px 10px 195px' });
    var divRegistro = $('div.divRegistros', '#divCarga');
    divRegistro.css({'padding-bottom':'1px'}); // 370px
    
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    var arrayAlinha = new Array();
    
    arrayLargura[0] = '47px';   //Codigo
    arrayLargura[1] = '250px';  //Modelo Score
    arrayLargura[2] = '79px';   //Data Atualizacao
    arrayLargura[3] = '79px';   //Data Inicio
    arrayLargura[4] = '79px';   //Data Final
    arrayLargura[5] = '79px';   //Usuario Responsavel
    arrayLargura[6] = '80px';   //Quantidade
    arrayLargura[7] = '78px';   //Quantidade Fisica
    arrayLargura[8] = '78px';   //Quantidade Juridica
    arrayLargura[9] = '79px';   //Situacao
    arrayLargura[10] = '14px';   // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem
    
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    arrayAlinha[6] = 'center';
    arrayAlinha[7] = 'center';
    arrayAlinha[8] = 'center';
    arrayAlinha[9] = 'center';
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    var num;
    $('table > tbody > tr', divRegistro).click( function() {
        num = $(this).attr('id');
        var dsrejeicao = $(this).find('#dsrejeicao').val();
        $('#divMotivo').css({ 'display': 'block' });
        $('table', '#divMotivo').find('#txtdsrejeicao').val(dsrejeicao);
    });
}

function initBotoesTabelaCarga(){
    $('#btAprovar', '#divBotoes').unbind('click').bind('click', function(){
        var linhaSel = $('table', '#divCarga').find('tr.corSelecao');
        validaPermissao('A', linhaSel);
    });

    $('#btRejeitar', '#divBotoes').unbind('click').bind('click', function(){
        var linhaSel = $('table', '#divCarga').find('tr.corSelecao');
        validaPermissao('R', linhaSel);
    });
}

function processarCarga(opcao, cdmodelo, dtbase, dsrejeicao){
    showMsgAguardo("Aguarde, processando carga ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/score/processar_carga.php",
        data: {
            cdmodelo: cdmodelo,
            dtbase: dtbase,
            cddopcao: opcao,
            dsrejeicao: dsrejeicao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                eval(response);
            } catch (error) {
                showError("error", "Não foi possível concluir a requisição. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
            }
        }
    });
}

function validaPermissao(cddopcao, linhaSel){
     showMsgAguardo("Aguarde, processando carga ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/score/valida_permissao.php",
        data: {
            cddopcao: cddopcao,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
        },
        success: function (response) {

            hideMsgAguardo();
            try {
                if (response ==''){
                    if(linhaSel.length == 0){
                        showError("inform", "Selecione pelo menos uma Carga para execu&ccedil;&atilde;o.", "Alerta - Ayllos", "");
                    } else {
                        var cdmodelo = $(linhaSel).attr('id');
                        var dsmodelo = $(linhaSel).find('td#dsmodelo').find('span').text();
                        var dtbase = $(linhaSel).find('td#dtbase').find('span').text();
                        var tipoExec = cddopcao == 'A' ? 'aprovar' : 'rejeitar';

                        if(cddopcao == 'A'){
                            showConfirmacao('Deseja realmente ' + tipoExec + ' a carga do modelo ' + dsmodelo + ' com data base ' + dtbase + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'processarCarga("' + cddopcao + '", "' + cdmodelo + '", "' + dtbase + '", "");', '', 'sim.gif', 'nao.gif');
                        } else{
                            showConfirmacao('Deseja realmente ' + tipoExec + ' a carga do modelo ' + dsmodelo + ' com data base ' + dtbase + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'mostrarMotivo("' + cdmodelo + '", "' + dtbase + '");', '', 'sim.gif', 'nao.gif');
                        }
                    }
                } else{
                    showError("error",response,'Alerta - Ayllos','',false);                         
                }
            } catch (error) {
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
            }
        }

    });
}

function mostrarMotivo(cdmodelo, dtbase){
	showMsgAguardo("Aguarde, processando carga ...");
	
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/score/form_motivo.php',
        data: {
            redirect: 'html_ajax'
        },
        error: function(objAjax,responseError,objExcept) {
            hideMsgAguardo();
            showError('error','Não foi possível concluir a requisição.','Alerta - Ayllos',"unblockBackground()");
        },
        success: function(response) {
            hideMsgAguardo();
            bloqueiaFundo($('#divRotina'));
            exibeRotina($('#divRotina'));
            $('#divRotina').html(response);
            formatarMotivo(cdmodelo, dtbase);
        }
    }); 
}

function formatarMotivo (cdmodelo, dtbase) {
    $('html, body').animate({scrollTop:0}, 'fast');
    $('#dsmotivo', '#frmMotivo').css({width:'500px', height:'100px'}).addClass('campo').focus().val('');
    
    $('#btContinuarMotivo').unbind('click').bind('click', function () {
        processarCarga('R', cdmodelo, dtbase, $('#dsmotivo', '#frmMotivo').val());
        return false;
    });
    
    $('#btVoltarMotivo').unbind('click').bind('click', function () {
        fechaRotina($('#divRotina'));
        return false;
    });
}
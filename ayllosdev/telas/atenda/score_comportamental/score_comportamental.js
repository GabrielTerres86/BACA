function acessaOpcaoAba(nrOpcoes, id, opcao) {

    // Mostra mensagem de aguardo
    showMsgAguardo('Aguarde, carregando...');

    // Atribui cor de destaque para aba da opção
    for (var i = 0; i < nrOpcoes; i++) {
        if (!$('#linkAba' + id)) {
            continue;
        }

        if (id == i) { // Atribui estilos para foco da opção
            $('#linkAba' + id).attr('class', 'txtBrancoBold');
            $('#imgAbaEsq' + id).attr('src', UrlImagens + 'background/mnu_sle.gif');
            $('#imgAbaDir' + id).attr('src', UrlImagens + 'background/mnu_sld.gif');
            $('#imgAbaCen' + id).css('background-color', '#969FA9');
            continue;
        }

        $('#linkAba' + i).attr('class', 'txtNormalBold');
        $('#imgAbaEsq' + i).attr('src', UrlImagens + 'background/mnu_nle.gif');
        $('#imgAbaDir' + i).attr('src', UrlImagens + 'background/mnu_nld.gif');
        $('#imgAbaCen' + i).css('background-color', '#C6C8CA');
    }

    // Carrega conteúdo da opção através do Ajax
    $.ajax({
        type: 'POST',
        dataType: 'html',
        url: UrlSite + 'telas/atenda/score_comportamental/principal.php',
        data: {
            nrdconta: nrdconta,
            redirect: 'html_ajax'
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError('error', 'N&atilde;o foi possível concluir a requisi&ccedil;&atilde;o.', 'Alerta - Ayllos', 'bloqueiaFundo(divRotina)');
        },
        success: function(response) {

            if (response.indexOf('showError("error"') == -1) {
                $('#divConteudoOpcao').html(response);
            } else {
                eval(response);
                controlaFoco(operacao);
            }

            return false;
        }
    });
}

function controlaLayout(){
    var divRegistro = $('div.divRegistros');
    $('#divConteudoOpcao').css('height', '100%');
    $('#divRotina').css({ 'width': '865px', 'left': '425px' });
    
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    var arrayAlinha = new Array();
    
    arrayLargura[0] = '82px';   //Modelo
    arrayLargura[1] = '95px';  //Data
    arrayLargura[2] = '196px';   //Classe
    arrayLargura[3] = '80px';   //Pontuação
    arrayLargura[4] = '145px';   //Exclusão Principal
    arrayLargura[5] = '78px';   //Situação
    arrayLargura[6] = '14px'; // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem
    
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    arrayAlinha[2] = 'center';
    arrayAlinha[3] = 'center';
    arrayAlinha[4] = 'center';
    arrayAlinha[5] = 'center';
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    initBotoes();
}

function initBotoes(){
    $('#btExclusao').unbind('click').bind('click', function(){
        var linhaSel = $('table', '#divScore').find('tr.corSelecao');
        var cdmodelo = $(linhaSel).attr('id');
        var dtbase = $(linhaSel).find('td#dtbase').find('span').text();
        if(linhaSel.length == 0 || cdmodelo == undefined){
            showError("error", "Selecione um score.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
        } else {
            exluirScore(cdmodelo, dtbase);
        }
    });
}

function exluirScore(cdmodelo, dtbase){
    showMsgAguardo("Aguarde, processando carga ...");

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/atenda/score_comportamental/excluir_score.php",
        data: {
            cdmodelo: cdmodelo,
            dtbase: dtbase,
            nrdconta: nrdconta,
            redirect: "script_ajax"
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "Não foi possível concluir a requisição.", "Alerta - Ayllos", "$('#btVoltar','#divBotoesBens').focus();");
        },
        success: function (response) {

           if (response.indexOf('showError("error"') == -1) {
                hideMsgAguardo();
                $('#divConteudoOpcao').html(response);
                controlaLayoutExc();
                //console.log(response);
            } else {
                eval(response);
            }

            return false;
        }
    });
}

function controlaLayoutExc(){
    var divRegistro = $('div.divRegistros');
    $('#divRotina').css({ 'width': '500px', 'left': '595px' });
    $('#divConteudoOpcao').css('height', '100%');
    
    var tabela      = $('table', divRegistro );
    var linha       = $('table > tbody > tr', divRegistro );

    var ordemInicial = new Array();

    var arrayLargura = new Array();
    var arrayAlinha = new Array();
    
    arrayLargura[0] = '60px';   //Codigo
    arrayLargura[1] = '';       //Exclusao
    arrayLargura[6] = '14px'; // Fixo para definir o tamanho da coluna do campo da ordenação inicial que fica sobre a barra de rolagem
    
    arrayAlinha[0] = 'center';
    arrayAlinha[1] = 'center';
    tabela.formataTabela( ordemInicial, arrayLargura, arrayAlinha, '' );

    $('#btVoltar').unbind('click').bind('click', function(){
        
    });
}
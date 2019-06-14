/*
Autor: Bruno Luiz Katzjarowski - Mout's
Data: 01/11/2018
Ultima alteração: 

Alterações:
 1 - Adicionar funcionaldiade de desabilitar campo cddopcao e apresentar/sumir campo de pesquisa
*/

/* 
Variaveis globais para salvar response da consulta de filtros 
*/
var aux_response_consultaC = undefined;
var aux_response_consultaM = undefined;
var aux_response_consultaS = undefined;


$(document).ready(function(){
    iniciarComponentes();
});

function iniciarComponentes(){
    habilitarDesabilitarCddopcao(true);
    habilitarDesabilitarFormFiltro(false);

    hideShowTabela(false); //Esconder tabelas
    atribuirEventos(); //Atribuir todos os eventos aos botoes iniciais
    atribuirMascaras(); //Atribuir as mascaras aos componentes

    controlaLayout();
}

function atribuirEventos(){

    /**
     * Desabilitar campo 'origem' quando 'tipo' for 'RECEBIDAS'
     */
    $('#selTipo', '#frmLogSPB').unbind("change").bind("change",function(e){
        if($(this).val() == "R"){
            $('#selOrigem', '#frmLogSPB').desabilitaCampo();
            $('#selOrigem', '#frmLogSPB').val("");
        }else{
            $('#selOrigem', '#frmLogSPB').habilitaCampo();
        }
    });


    /** 
    * Atribuir evento a botão voltar da consulta de mensagens
    */
    $('#btVoltarConsulta').unbind('click').bind('click',function(e){
        e.preventDefault();
        habilitarCamposFiltros(true);
        //$('#frmCamposTelaLogSPB').hide(); //Esconder tabela
        hideShowTabela(false);
        $('#selCooperativas').focus();
        return false;
    });

    /**
     * Atribuir eventos de páginacao
     */
    $('#pagVoltar','#divRegistrosRodape').unbind().bind('click',function(e){
        e.preventDefault();
        var nriniseq = $(this).data('nriniseq');
        var nrregist = $(this).data('nrregist');
        consultarMensagens({acao: 'VOLTAR',nriniseq: nriniseq-nrregist});
        return false;
    });
    $('#pagProximo','#divRegistrosRodape').unbind().bind('click',function(e){
        e.preventDefault();
        var nriniseq = $("#pagVoltar",'#divRegistrosRodape').data('nriniseq');
        var nrregist = $("#pagVoltar",'#divRegistrosRodape').data('nrregist');
        consultarMensagens({acao: 'PROXIMA',nriniseq: nriniseq+nrregist});
        return false;
    });


    $('#btVoltar', '#frmLogSPB').unbind('click').bind('click',function(){
        habilitarDesabilitarFormFiltro(false);
        habilitarDesabilitarCddopcao(true);
        $('#cddopcao').focus();
    });

    /* 
    Atruibir eventos de busca para o campo de cddopcao
    Obs: Observar o unbind('click') em habilitarDesabilitarCddopcao para este botao.
    */
    $('#btSelecionaOpcao').unbind('click').bind('click',function(){
        habilitarDesabilitarCddopcao(false);
	    habilitarCamposFiltros(true);
        carregaComboBoxesFiltro(); //carregar comboboxes
    });

    /* Atruibir eventos de on change ao combo box de opção */
    $('#cddopcao').unbind('change').bind('change',function(){
        mudarOpcao($(this).val());
    });

    /* Atruibir evento ao botão de consulta do filtro*/
    $('#btConsultar', '#frmLogSPB').unbind('click').bind('click',function(e){
        e.preventDefault();
        $(this).blur(); //Remover foco do campo
        consultarMensagens();
        return false;
    });

    /* Atribuir evento ao botão de voltar do modal */
    $('#btFechaConsulta').unbind('click').bind('click',function(e){
        e.preventDefault();
        fechaRotina($('#divRotina'));
        return false;
    });

    /* Atribuit evento ao botão de impressao CSV */
    $('#btCsv').unbind('click').bind('click',function(e){
        e.preventDefault();
        if($('#cddopcao').val() == "S"){
            showConfirmacao('Deseja exportar relat&oacute;rio?', 'Confirma&ccedil;&atilde;o - Ayllos', 'imprimirCSV();', '', 'sim.gif', 'nao.gif');
        }else{
            enviarEmail();
        }
        $(this).blur();
        return false;
    });

    /* Atribuit evento ao botão de impressao PDF */
    $('#btPdf').unbind('click').bind('click',function(e){
        e.preventDefault();
        imprimirPDF();
        $(this).blur();
        return false;
    });

     /* Atribuit evento ao botão de Envio do relatorio por e-mail */
     $('#btEnviarEmail').unbind('click').bind('click',function(e){
        e.preventDefault();
        var ret = validarCamposEmail();
        $(this).blur();
        if(!ret.ret){
            showError("error", ret.msg, "Alerta - Aimaro", "blockBackground(1);");
        }else{
            consultarMensagens(undefined, $('#dsendere').val());
        }
        return false;
    });
}

function enviarEmail(){
    $('#detalhesConsultaCM').hide();
    $('#detalhesConsultaS').hide();
    
    //Mostrar div de envio de e-mail
    $('#envioEmail').show();
    $('#btEnviarEmail').show();
    $('#linkAba0').html('Gera&ccedil;&atilde;o do Arquivo');
    $('.botoesLogspb').css({'border-top': '0px solid black'});

    /**
     * Ajustar layout da tela de envio de e-mail
     */
    if(detectIE()){
        $('#fsEnvioEmail').css({
            'border':'1px solid #bbbbbb',
            'padding-right': '15px',
            'padding-left': '15px',
            'padding-bottom': '15px',
            'margin': '7px'
        });
        $('#classBlocoEmail').css({
            'padding-top': '10px'
        });
    }else{
        $('#fsEnvioEmail').css({
            'border':'1px solid #bbbbbb',
            'padding': '15px',
            'margin': '7px'
        });
    }

    if(detectIE()){
        $('#fsEnvioEmail legend').css({
            'margin-left':'45px',
            'padding-left': '10px',
            'padding-right': '10px'
        }); 
    }else{
        $('#fsEnvioEmail legend').css({
            'padding-left': '10px',
            'padding-right': '10px'
        }); 
    }

    $('#dsendere').css({
        'width': '390px'
        //'padding-top': '10px'
    });

    // $('label[for="dsendere"]').css({
    //     'padding-top': '10px'
    // });

    $('#btFechaConsulta').text('Cancelar');
    $('#divBotoesModal').css({
        'margin-top': '2px'
    });

    blockBackground(1);
    carregarLayoutEmail();
    exibeRotina($('#divRotina'));
}


function habilitarCamposFiltros(habilitar){
    if(typeof habilitar == 'undefined')
        habilitar = false;

    $('input','#frmLogSPB').each(function(i,campo){
        if(habilitar){
            $(campo).habilitaCampo();
        }else{
            $(campo).desabilitaCampo();
            $(campo).attr('disabled',false);
        }
    });

    $('select','#frmLogSPB').each(function(i,campo){
        if(habilitar){
            $(campo).habilitaCampo();
        }else{
            $(campo).desabilitaCampo();
        }
    });

    aplicarRegrasFiltros();

    //Esconder botoes voltar|continuar do form de filtro
    if(habilitar)
        $('#divBotoesFiltroBuscaGrupo','#frmLogSPB').show(); 
    else
        $('#divBotoesFiltroBuscaGrupo','#frmLogSPB').hide();
}

function aplicarRegrasFiltros(){

    var cddopcao = $('#cddopcao').val();

    if(cddopcao == 'S'){ //se opção é S tipo é Recebida, seleciona
        var selTipo = $('#selTipo');
        $(selTipo).val('R');
        $(selTipo).desabilitaCampo();
    }

}

function imprimirCSV(){
    $('#aux_cddopcao','#frmLogSPB').val($('#cddopcao').val());
    var campos = $('#frmLogSPB');

    $(campos).attr('target','_blank');
    $('select','#frmLogSPB').each(function(i,campo){
        $(campo).attr('disabled',false);
    });

    $(campos).attr('action','imprimir_csv.php');
    $(campos).submit();
}
function imprimirPDF(){
    $('#aux_cddopcao','#frmLogSPB').val($('#cddopcao').val());
    var campos = $('#frmLogSPB');
    $(campos).attr('target','_blank');

    $('select','#frmLogSPB').each(function(i,campo){
        $(campo).attr('disabled',false);
    });

    $(campos).attr('action','imprimir_pdf.php');
    $(campos).submit();
}


function getDetalhesMensagem(linha){

    /** 
     * se a linha se perdeu ou o dom não tinha atualizado a tempo de a linha ainda existir
     * atualizar a variavel para recuperar o numero de nrseq
     */
    if(linha.length == 0){
        linha = $('.corSelecao','.tabelaConsultaLog');
    }

    var data = {
        parametros: {
                idorigem: $(linha).data('idorigem'),
                nrseq_mensagem: $(linha).data('nrseq_mensagem')
            },
        chamada: 'GET_DETALHES_MENSAGEM',
        redirect: "script_ajax" // Tipo de retorno do ajax
    };

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/logspb/chamadas.php",
        dataType: 'json',
        data: data,
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            location.reload();
            //showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "location.reload();");
        },
        beforeSend: function(){
            showMsgAguardo('Aguarde, consultando.');
        },
        success: function (response) {
            if(response.error != ""){
                eval(response.error);
            }else{
                carregaDetalhesDaMensagem(response,linha);
            }
        },
        complete: function(){
            $('#divAguardo').hide(); //Dar hide no div de mensagem de aguarde para que o blockBackground funcione.
        }
    });
}

function consultarMensagens(paginacao,dsendere){

    if(typeof paginacao == "undefined"){
        paginacao = {
            acao: '',
            nriniseq: 0
        };
    }

    /** 
     * É obrigado a fazer isso pois não é possivel inserir um valor padrão para o parametro devido ao modo
     * de compatibilidade do IE estar ligado. (verão do javascript fica anterior a esta issue)
    */
    if(typeof dsendere == "undefined"){
        dsendere = "";
    }

    var data = {
        parametros: {
                opcao: $('#cddopcao').val(),
                dtmensagem_de:  $('#textDataDe').val(),
                dtmensagem_ate: $('#textDataAte').val(),
                vlmensagem_de: $('#textValorDe').val(),
                vlmensagem_ate: $('#textValorAte').val(),
                intipo: $('#selTipo').val(),
                nrispbif: $('#selIfContraparte').val(),
                inorigem: $('#selOrigem').val(),
                cdcooper: $('#selCooperativas').val(),
                nrdconta: $('#selContaDv').val(),
                paginacao: paginacao,
                dsendere: dsendere
            },
        chamada: 'GET_CONSULTA',
        redirect: "script_ajax" // Tipo de retorno do ajax
    };


    $.ajax({
        type: "POST",
        url: UrlSite + "telas/logspb/chamadas.php",
        dataType: 'json',
        data: data,
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            location.reload();
            //showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "location.reload();");
        },
        beforeSend: function(){
            showMsgAguardo('Aguarde, consultando.');
        },
        success: function (response) {
            if(response.error != ""){
                eval(response.error);
            }else{
                if(dsendere != ""){
                    mensagemRetornoEmail();
                }else{
                    carregaTabelas(response);
                }
            }
        },
        complete: function(i){
        }
    });
}



function carregaComboBoxesFiltro(){

    /** 
     * Carregar filtros utilizando o response do ajax
    */
    var opcao = $('#cddopcao').val();
    switch(opcao){ //C | M | S
        case 'M':
        case 'C':
            if(aux_response_consultaC != undefined){
                carregaOpcoesFiltro(aux_response_consultaC);
                habilitarDesabilitarFormFiltro(true);
                return false;
            }
        break;
        case 'S':
            if(aux_response_consultaS != undefined){
                carregaOpcoesFiltro(aux_response_consultaS);
                habilitarDesabilitarFormFiltro(true);
                return false;
            }
        break;
    }

 
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/logspb/chamadas.php",
        dataType: 'json',
        data: {
            chamada: 'GET_OPCOES',
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        beforeSend: function(){
            showMsgAguardo('Aguarde, carregando.');
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            location.reload();
            //showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "location.reload();");
        },
        success: function (response) {
            if(response.error != ""){
                eval(response.error);
            }else{
                switch(opcao){
                    case 'M':
                    case 'C':
                        aux_response_consultaC = response;
                    break;
                    case 'S':
                        aux_response_consultaS = response;
                    break;
                }
                carregaOpcoesFiltro(response);
            }
        },
        complete: function(i){
            habilitarDesabilitarFormFiltro(true);
        }
    });

}

function carregaOpcoesFiltro(response){
    carregaComboCooperativas(response);
    carregaComboTipo(response);
    carregaComboIfContraparte(response); 
    carregaComboOrigem(response);
    carregarCampos();
    hideMsgAguardo();
}

function carregarCampos(){
    $('#textDataDe').val(getDataAtual());
    $('#textDataAte').val(getDataAtual());

    $('#textValorDe').val('');
    $('#textValorAte').val('');
}

//selOrigem
function carregaComboOrigem(response){

    var cbOrigem = $('#selOrigem');
    var arrOrigem = response.retorno.origem;
    $(cbOrigem).find('option').remove();
    // item3: {inorigem: "C", dsorigem: "Caixa Online"}

    $(cbOrigem).append($('<option>',{
        value: '',
        text: ''
    }));

    if(typeof arrOrigem.item3.length == "number"){

        var arrOrigemItem3 = arrOrigem.item3;

        for (var i = 0; i < arrOrigemItem3.length; i++) {
            var elemItem3 = arrOrigemItem3[i];
            $(cbOrigem).append($('<option>',{
                value: elemItem3.inorigem,
                text: elemItem3.dsorigem
            }));
        }

    }else{
        $(cbOrigem).append($('<option>',{
            value: arrOrigem.item3.inorigem,
            text: arrOrigem.item3.dsorigem
        }));
    }
}

function carregaComboIfContraparte(response){

    var cbContraparte = $('#selIfContraparte');
    var arrContraparte = response.retorno.IfContraparte;
    $(cbContraparte).find('option').remove();
    //{nrispbif: "3532415", dsispbif: "3532415-ABN AMRO"}

    if(typeof arrContraparte.item1.length == "number"){

        var arrContraparteItem1 = arrContraparte.item1;
        for (var i = 0; i < arrContraparteItem1.length; i++) {
            var elemItem1 = arrContraparteItem1[i];
            var selected = false;
            if(elemItem1.dsispbif == '0 - TODOS')
                selected = true;

            $(cbContraparte).append($('<option>',{
                value: elemItem1.nrispbif,
                text: elemItem1.dsispbif,
                selected: selected
            }));
        }

    }else{
        $(cbContraparte).append($('<option>',{
            value: arrContraparte.item1.nrispbif,
            text: arrContraparte.item1.dsispbif
        }));
    }
}

/*
    Todas as regras para o campo de filtro "Tipo"
    @param response Response da chamada de pc_busca_filtro
*/
function carregaComboTipo(response){

    var cbTipo = $('#selTipo');
    var arrTipo = response.retorno.tipo;
    $(cbTipo).find('option').remove();
    //{intipo: "T", dstipo: "Todas"}

    var cddopcao = $('#cddopcao').val();


    if(typeof arrTipo.item2.length == "number"){
        var arrTipoItem2 = arrTipo.item2;
        for (var i = 0; i < arrTipoItem2.length; i++) {
            var itemTipo = arrTipoItem2[i];
            var selected = false;
            if(cddopcao == 'S' && itemTipo.intipo == "R"){ //se opção é S tipo é Recebida, seleciona
                selected = true;
            }

            $(cbTipo).append($('<option>',{
                value: itemTipo.intipo,
                text: itemTipo.dstipo,
                selected: selected
            }));
        }
    }else{
        var selected = false;
        if(cddopcao == 'S' && arrTipo.item2.intipo == "R"){ //se opção é S tipo é Recebida, seleciona
            selected = true;
        }
        $(cbTipo).append($('<option>',{
            value: arrTipo.item2.intipo,
            text: arrTipo.item2.dstipo,
            selected: selected
        }));
    }

    if(cddopcao == 'S'){ //Se a opção selecionada é "S" combobox tipo é desabilitado
        $(cbTipo).desabilitaCampo();
    }else{
        $(cbTipo).habilitaCampo();
    }
}

function carregaComboCooperativas(response){

    var cbCooperativas = $('#selCooperativas');
    var arrCooperativas = response.retorno.cooperativas;
    $(cbCooperativas).find('option').remove();
    //{codigo: '', nome: ''}
    
    if(typeof arrCooperativas.item.length == "number"){

        var item = arrCooperativas.item; 

        for (var i = 0; i < item.length; i++) {
            var coop = item[i];

            //Selecionar somente se for cooperativa 3 (Ailos)
            var sel = false;
            if(cdcooper == 3 && coop.codigo == 3){
                sel = true;
            }

            $(cbCooperativas).append($('<option>',{
                value: coop.codigo,
                text: coop.nome,
                selected: sel
            }));
        }

    }else{
        $(cbCooperativas).append($('<option>',{
            value: arrCooperativas.item.codigo,
            text: arrCooperativas.item.nome
        }));
    }
}

function atribuirMascaras(){
    layoutPadrao();
    $('#textDataDe').mask('00/00/0000');
    $('#textDataAte').mask('00/00/0000');

    $('#selContaDv').bind("keyup", function (e) {
        if (!$(this).setMaskOnKeyUp("INTEGER", "zzzz.zzz-z", "", e)) {
            return false;
        }
    });
    $('#selContaDv').bind("keydown", function (e) {
        return $(this).setMaskOnKeyDown("INTEGER", "zzzz.zzz-z", "", e);
    });
}

/*
    Disparar evento de mudança do combo box de opções
    @return void;
*/
function mudarOpcao(opcao){
    switch(opcao){
        case 'S':
            $('#blocoOpcao2').hide();
            break;
        default:
            $('#blocoOpcao2').show();
            break;
    }
}


/*
    Esconder ou mostrar a tabela de consulta
    @param mostrar true|false Mostrar ou não
*/
function hideShowTabela(mostrar){
    if(typeof mostrar == "undefined")
        mostrar = true;

    if(mostrar){
        $(".divTabelaLogSpb").show(); 
        $('.divBotoesDetalhes').show();
        $('#frmCamposTelaLogSPB').show();
    }else{
        $(".divTabelaLogSpb").hide(); 
        $('.divBotoesDetalhes').hide(); 
        $('#frmCamposTelaLogSPB').hide();
    }
}


// Função para visualizar div da rotina
function mostraRotina() {
    $("#divRotina").css("visibility", "visible");
    $('#divRotina').css({ 'margin-left': '', 'margin-top': '' }); // Restaurar valores
    $("#divRotina").centralizaRotinaH();

}

// Função para esconder div da rotina e carregar dados da conta novamente
function encerraRotina() {

    //Condição para voltar foco na opção selecionada
    var CaptaIdRetornoFoco = '';
    CaptaIdRetornoFoco = $(".SetFoco").attr("id");
    if (CaptaIdRetornoFoco) {
        $(CaptaIdRetornoFoco).focus();
    }

    unblockBackground();
    $("#divRotina").css({ "width": "545px", 'margin-left': '', 'margin-top': '', "visibility": "hidden" });
    $("#divRotina").html("");
}

function ajustarCentralizacao() {
    var wAll = parseInt($('#tdConteudoTela').css('width'));
    var wUse = 950;//$('#divRotina').css('width');

    var leftPx = ((wAll-wUse)/2)+178;
    $('#divRotina').css({
        'position':'absolute',
        'top': '91px',
        'left': leftPx
    });
}

function getDataAtual(){
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
     yyyy = today.getFullYear();

    if(dd<10) {
        dd = '0'+dd
    } 

    if(mm<10) {
        mm = '0'+mm
    }

    return today = dd + '/' + mm + '/' + yyyy;
}

function habilitarDesabilitarCddopcao(habilitar){
    if(typeof habilitar == 'undefined')
        habilitar = false;
    
    if(habilitar){
        $('#cddopcao').habilitaCampo();
        $('#btSelecionaOpcao').habilitaCampo();
        $('#btSelecionaOpcao').unbind('click').bind('click',function(){
            habilitarDesabilitarCddopcao(false);
            habilitarCamposFiltros(true);
            carregaComboBoxesFiltro(); //carregar comboboxes
        });
    }else{
        $('#cddopcao').desabilitaCampo();
        $('#btSelecionaOpcao').unbind('click');
    }
}

function habilitarDesabilitarFormFiltro(habilitar){
    if(typeof habilitar == 'undefined')
        habilitar = false;

    if(habilitar){
        $('#frmLogSPB').show();
        $('#selCooperativas', '#frmLogSPB').focus();
    }else{ //DESABILITAR FORM DE FILTRO
        $('#frmCamposTelaLogSPB').hide();
        $('#frmLogSPB').hide();
    }
}

function detectIE() {
    var ua = window.navigator.userAgent;

    var msie = ua.indexOf('MSIE ');
    if (msie > 0) {
        // IE 10 or older => return version number
        return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
    }

    var trident = ua.indexOf('Trident/');
    if (trident > 0) {
        // IE 11 => return version number
        var rv = ua.indexOf('rv:');
        return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
    }

    var edge = ua.indexOf('Edge/');
    if (edge > 0) {
       // Edge (IE 12+) => return version number
       return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
    }

    // other browser
    return false;
}

/**
 * @return true|false se os campos estão validos, true. Se não, false.
 */
function validarCamposEmail(){ 

    var valida = {
        ret: true,
        msg: ''
    };

    if($('#dsendere').val() == ""){
        valida.ret = false;
        valida.msg = 'Favor inserir um e-mail.';
        return valida;
    }

    valida.ret = validateEmail($('#dsendere').val());
    if(!validateEmail($('#dsendere').val())){
        valida.msg = 'E-mail inv&aacute;lido.';
        return valida;
    }


    return valida;
}
function validateEmail(email) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
  }

  function mensagemRetornoEmail(){
    var msg = "Solicita&ccedil;&atilde;o efetuada com sucesso. ";
    msg += "O arquivo est&aacute; sendo gerado e voc&ecirc; receber&aacute; um aviso de confirma&ccedil;&atilde;o por e-mail.";
    showError("inform", msg, "Alerta - Aimaro", "fechaRotina($('#divRotina')); hideMsgAguardo();$('#dsendere').val('');");
  }

function carregarLayoutEmail(){
    $('#divConteudoOpcao').css({
        'width': '517px'
    });
}

function controlaLayout(){
    $('#frmLogSPB').addClass('semBordaTop');
    $('#frmLogSPB').addClass('semBordaBottom');
}
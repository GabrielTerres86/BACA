/**
 * Autor: Bruno Luiz Katzajarowski - Mout's
 * Data: 01/03/2019
 * Ultima alteração:
 */

/**
 * CONSTANTES
 */
var hasOpcaoAberta = false;
var _dataAtual = "";
var _modalEmailAberto = false;

 $(function(){

    addFuncoesIE();

    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();

    _dataAtual = dd + '/' + mm + '/' + yyyy;

    inciarComponentes();
    atribuirEventos();
    atribuirEventosCampos();

 });

/**
 * Atribuir eventos aos controles da tela conspb
 */
 var atribuirEventos = function(){
    $('#btOkTopo').unbind('click').bind('click',function(){
        var opcao = $('#boxSelecao').val();
        showDivOpcao(opcao);
        $('#boxSelecao').desabilitaCampo();

        switch(opcao){
            case 'A':
                setFocus('#horaConciliacao');
                break;
            case 'C':
                setFocus('#mensagem');
                break;
        }
        hasOpcaoAberta = true;
    });

    $('#btVoltar').unbind('click').bind('click',function(){
        if(hasOpcaoAberta){
            resetarConspb();
            hasOpcaoAberta = false;
        }
    });

    $('#tdTela').unbind('keydown').bind('keydown',function(e){
        console.log(e.keyCode);
        if(e.keyCode == 13 || e.keyCode == 9){ //13 = enter | 9 = tab
        }
    });

 }

/**
 * Iniciar os componentes da tela.
 */
 var inciarComponentes = function(){
    $('#opcaoC').hide();
    $('#opcaoA').hide();
    $('#divBotoes').hide();

    $('#periodoDe,#periodoAte').val(_dataAtual);
 }

 /**
  * Mostrar div correspondente ao selecionado em cdopcao
  * @param {string} opcao Valor da opção de abertura
  */
 var showDivOpcao = function(opcao){

    switch(opcao){
        case 'A':
            $('#opcaoA').show();
            $('#opcaoC').hide();
            $('#btConciliar').val('Concluir');
            consultarOpcaoA();
            atribuirEventosOpcaoA();
            break;
        case 'C':
            $('#opcaoC').show();
            $('#opcaoA').hide();
            $('#btConciliar').val('Conciliar');
            atribuirEventosOpcaoB();
            break;
    }
    $('#divBotoes').show();
 }


 /**
  * Setar o foco em um determinado campo
  * @param {string} elem Elemento à receber o foco
  */
 var setFocus = function(elem){
    if(elem.indexOf("#") === -1){
        elem = "#"+elem;
    }
    $(elem).focus();
 }

 /**
  * Resetar o fluxo da tela.
  */
 var resetarConspb = function(){
    $('#boxSelecao').habilitaCampo(); 
    $('#boxSelecao').focus(); 
    $('#opcaoC').hide();
    $('#opcaoA').hide();
    $('#divBotoes').hide();

    resetarOpcaoB();
 }

/**
 * Resetar campos opção B
 */
 var resetarOpcaoB = function(){
    $('#periodoDe,#periodoAte').val(_dataAtual); //Atualizar campos de data
    $('#dsendere').val(""); //Atualizar campos de data
 }

 var atribuirEventosCampos = function(){

    atribuirEventosOpcaoA();
    atribuirEventosOpcaoB();

 }


/**
 * Atribuir evento aos campos da Opção A
 */
 var atribuirEventosOpcaoA = function(){

    /** 
     * Evento campo unico da opção A
    */
    $('#horaConciliacao').unbind('keydown').bind('keydown',function(e){
        if(e.keyCode == 13 || e.keyCode == 9){ //13 = enter | 9 = tab
            $('#btConciliar').focus();
        }
    });
    $('#horaConciliacao').mask('99:99');

    $('#btConciliar').unbind('click').bind('click',function(){
        salvarOpcaoA();
    });

 }

/**
 * Atribuir eventos aos campos da opção 'C'
 */
 var atribuirEventosOpcaoB = function(){

   $('#mensagem').unbind('keydown').bind('keydown',function(e){
        if(e.keyCode == 13 || e.keyCode == 9){ //13 = enter | 9 = tab
            setFocus('#periodoDe');
        }
        return false;
    });

    $('#periodoDe').unbind('keydown').bind('keydown',function(e){
        if(e.keyCode == 13 || e.keyCode == 9){ //13 = enter | 9 = tab
            setFocus('#periodoAte');
        }
        return false;
    });
    $('#periodoDe').setMask("DATE", "", "", "");

    $('#periodoAte').unbind('keydown').bind('keydown',function(e){
        if(e.keyCode == 13 || e.keyCode == 9){ //13 = enter | 9 = tab
            setFocus('#btConciliar');
        }
        return false;
    });
    $('#periodoAte').setMask("DATE", "", "", "");

    $('#btConciliar').unbind('click').bind('click',function(){
        if(validaConciliacao()){
            abrirModalEmail();
            setFocus('#dsendere');
        }
    });
    
 }

/**
 * Salvar dados para opção A
 */
 var salvarOpcaoA = function(){
    alterarOpcaoA();
 }

 /**
  * Consultar Opção A
  */
 var consultarOpcaoA = function(){

    var data = {
        parametros: {
                cddopcao: $('#boxSelecao','.formCabecalho').val()
            },
        chamada: 'CONSULTAR_AGEND_CON',
        redirect: "script_ajax" // Tipo de retorno do ajax
    };

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/conspb/includes/chamadas.php",
        dataType: 'json',
        data: data,
        error: function (objAjax, responseError, objExcept) {
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "location.reload();");
        },
        beforeSend: function(){
            showMsgAguardo('Aguarde, consultando.');
        },
        success: function (response) {
            if(!validaErro(response)){
                var retorno = response.retorno;
                var hragendconciliacao = retorno.parametros.parametro.hragendconciliacao;
                $('#horaConciliacao','#opcaoA').val(hragendconciliacao);
            }
        },
        complete: function(){
            hideMsgAguardo();
        }
    });

 }

 /**
  * Alterar dados da opção A
  */
 var alterarOpcaoA = function(){
    if(!validarDadosOpcaoA()){return false;}
    var data = {
        parametros: {
                cddopcao: $('#boxSelecao','.formCabecalho').val(),
                dhagendcon: $('#horaConciliacao','#opcaoA').val()
            },
        chamada: 'ALTERAR_AGEND_CONCILIACAO',
        redirect: "script_ajax" // Tipo de retorno do ajax
    };

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/conspb/includes/chamadas.php",
        dataType: 'json',
        data: data,
        error: function (objAjax, responseError, objExcept) {
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "location.reload();");
        },
        beforeSend: function(){
            showMsgAguardo('Aguarde, consultando.');
        },
        success: function (response) {
            if(!validaErro(response)){
                messageAviso("A altera&ccedil;&atilde;o deste par&acirc;metro somente ser&aacute; v&aacute;lida no pr&oacute;ximo dia &uacute;til",'resetarConspb();');
            }
        },
        complete: function(){
            hideMsgAguardo();
        }
    });
 }

 /**
  * Validar dados da opção A
  */
 var validarDadosOpcaoA = function(){

    //Validar valor
    var dhagendcon = $('#horaConciliacao','#opcaoA').val();
    if(dhagendcon === ""){
        showError('error', "Hora de concilia&ccedil;&atilde;o di&aacute;ria &eacute; obrigat&oacute;ria.", 'Alerta - Aimaro','');
        return false;
    }

    var validaHora = function(hora){
        var regex = /^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/;
        return regex.test(hora);
    }

    if(!validaHora(dhagendcon)){
        showError('error', "Hora de concilia&ccedil;&atilde;o di&aacute;ria inv&aacute;lida.", 'Alerta - Aimaro','');
        return false;
    }

    return true;
 }

 /**
  * Validar retorno
  * @param {object} response
  * @return {boolean} true -> Contem erro || false -> Não contem erro 
  */
 var validaErro = function(response, acao){
     if(typeof acao === 'undefined'){acao = '';}
     console.log(response);
     if(typeof response.erro !== 'undefined'){
        showError('error', response.erro.Erro.Registro.dscritic, 'Alerta - Aimaro',acao);
        setTimeout('bloqueiaFundoMsgErro();',1/10);
        return true;
     }
     return false;
 }

 /**
  * enviar uma mensagem de aviso
  * @param {string} msg Mensagem de aviso "inform"; 
  * @param {string} acao Acao ao clicar em OK
  * @param {string} tipo Tipo da mensagem de aviso (inform | error)
  */
 var messageAviso = function(msg, acao,tipo){
     if(typeof acao === 'undefined'){acao = '';}
     if(typeof tipo === 'undefined'){tipo = 'inform';}
     showError(tipo, msg, "Alerta - Aimaro", acao);setTimeout('bloqueiaFundoMsgErro();',1);
    }

 
 /**
  * Bloquear fundo atrás da mensagem de erro
  */
 var bloqueiaFundoMsgErro = function(){blockBackground(91);}

 function addFuncoesIE(){
     if(detectIE()){

        if (!String.prototype.repeat) {
            String.prototype.repeat = function(count) {
                'use strict';
                if (this == null) {
                    throw new TypeError('can\'t convert ' + this + ' to object');
                }
                var str = '' + this;
                count = +count;
                if (count != count) {
                    count = 0;
                }
                if (count < 0) {
                    throw new RangeError('repeat count must be non-negative');
                }
                if (count == Infinity) {
                    throw new RangeError('repeat count must be less than infinity');
                }
                count = Math.floor(count);
                if (str.length == 0 || count == 0) {
                    return '';
                }
                // Ensuring count is a 31-bit integer allows us to heavily optimize the
                // main part. But anyway, most current (August 2014) browsers can't handle
                // strings 1 << 28 chars or longer, so:
                if (str.length * count >= 1 << 28) {
                    throw new RangeError('repeat count must not overflow maximum string size');
                }
                var maxCount = str.length * count;
                count = Math.floor(Math.log(count) / Math.log(2));
                while (count) {
                    str += str;
                    count--;
                }
                str += str.substring(0, maxCount - str.length);
                return str;
            }
        }

        if (!String.prototype.padStart) {
            String.prototype.padStart = function padStart(targetLength,padString) {
                targetLength = targetLength>>0; //truncate if number or convert non-number to 0;
                padString = String((typeof padString !== 'undefined' ? padString : ' '));
                if (this.length > targetLength) {
                    return String(this);
                }
                else {
                    targetLength = targetLength-this.length;
                    if (targetLength > padString.length) {
                        padString += padString.repeat(targetLength/padString.length); //append to original to ensure we are longer than needed
                    }
                    return padString.slice(0,targetLength) + String(this);
                }
            };
        }

    } //Fim detectIE();
 }

/**
 * Autor: Bruno Luiz Katzjarowski - Mout's
 * Data: 12/05/2019
 * 
 * Ultima alteração:
 *      20/05/2019 - Alterar criticas e algumas regras de validações - Bruno Luiz K. - Mout's
 */

/**
 * Atribuir eventos aos botões do modal de E-mail
 */
function atribuirEventosModal(){
    /* Atribuir evento ao botão de voltar do modal */
    $('#btFechaConsulta').unbind('click').bind('click',function(e){
        e.preventDefault();
        fechaRotina($('#divRotina'));
        _modalEmailAberto = false;
        return false;
    });

    $('#btEnviarEmail').unbind('click').bind('click',function(){
        executarConciliacaoManual();
    });

     $('#dsendere').unbind('keydown').bind('keydown',function(e){
        if(e.keyCode == 13 || e.keyCode == 9){ //13 = enter | 9 = tab
            setFocus('#btEnviarEmail');
        return false;
        }
    });
}

/**
 * Executar requisição de conciliação manual
 */
var executarConciliacaoManual = function(){

    var valido = validarCamposEmail();
    if(!valido.ret){
        showError('error', valido.msg, 'Alerta - Aimaro','blockBackground(1);setFocus("#dsendere");');
        return false;
    }

    var data = {
        parametros: {
                horarioOpcao: $('#mensagem').val(), 
                periodoDe: $('#periodoDe').val(),
                periodoAte: $('#periodoAte').val(),
                dsendere: $('#dsendere').val(),
                cddopcao: $('#boxSelecao','.formCabecalho').val()
            },
        chamada: 'EXECUTA_CONCILIACAO_MANUAL',
        redirect: "script_ajax" // Tipo de retorno do ajax
    };

    $.ajax({
        type: "POST",
        url: UrlSite + "telas/conspb/includes/chamadas.php",
        dataType: 'json',
        data: data,
        error: function (objAjax, responseError, objExcept) {
            console.log(responseError);
            showError("error", "asdf N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro","blockBackground(1)");
        },
        beforeSend: function(){
            showMsgAguardo('Aguarde, consultando.');
        },
        success: function (response) {
            // Valida requisição, caso false, executa blockBackground 
            // para deixar fundo preto no modal do e-mail
            if(!validaErro(response,'blockBackground(1)')){
                messageAviso("Solicita&ccedil;&atilde;o efetuada com sucesso. A concilia&ccedil;&atilde;o est&aacute; sendo processada e voc&ecirc; receber&aacute; uma notifica&ccedil;&atilde;o por e-mail quando estiver conclu&iacute;da",
                'fechaRotina($("#divRotina"));resetarConspb();');
            }
        },
        complete: function(){
            hideMsgAguardo();
        }
    });
}

/**
 * Validar campos de conciliação
 */
function validaConciliacao(){
    /**
     * Validar Inserção de Dados nos campos de datas
     */
    if($('#periodoDe').val() === ''|| $('#periodoAte').val() === ''){
        messageAviso("Informe o Per&iacute;odo.", "setFocus('#periodoAte')",'error');
        return false;
    }
    
    /**
     * Validar Hora
     */
    if(!validatePeriodo($('#periodoDe').val(),$('#periodoAte').val())){
        messageAviso("Per&iacute;odo inv&aacute;lido.", "setFocus('#periodoAte')",'error');
        return false;
    }

    return true;
}

/**
 * Abrir modal de requisição de campo e-mail
 */
function abrirModalEmail(){
    
    //Mostrar div de envio de e-mail
    $('#envioEmail').show();
    $('#btEnviarEmail').show();
    $('#linkAba0').html('Concilia&ccedil;&atilde;o');
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
    });

    $('#btFechaConsulta').text('Cancelar');
    $('#divBotoesModal').css({
        'margin-top': '2px'
    });

    blockBackground(1);
    carregarLayoutEmail();
    exibeRotina($('#divRotina'));
    atribuirEventosModal();

    _modalEmailAberto = true;
}

/**
 * Carregar layout modal de E-mail
 */
function carregarLayoutEmail(){
    $('#divConteudoOpcao').css({
        'width': '517px'
    });
}

/**
 * Detectar Internet Explorer
 */
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
 * Validar campos de e-mail
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

/**
 * Validar string contendo e-mail (regex)
 * @param {string} email 
 */
function validateEmail(email) {
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
  }

/**
 * Validar se dataAte é maior que dataDe ou se os valores estão vazios
 * @param {string} dataDe  dd/mm/yyyy
 * @param {string} dataAte dd/mm/yyyy 
 */
function validatePeriodo(dataDe, dataAte){
    
    if(typeof dataDe == 'undefined'  || dataDe == null){return false;}
    if(typeof dataAte == 'undefined' || dataAte == null){return false;}

    var arrStartDate = dataDe.split("/");
    var date1 = new Date(arrStartDate[2], arrStartDate[1], arrStartDate[0]);
    var arrEndDate = dataAte.split("/");
    var date2 = new Date(arrEndDate[2], arrEndDate[1], arrEndDate[0]);

    if(date2 < date1){
        return false;
    }

    return true;
  }
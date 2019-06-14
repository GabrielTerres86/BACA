/* !
 * FONTE        : valbol.js
 * CRIACAO      : Carlos Rafael Tanholi / CECRED
 * DATA CRIACAO : 24/04/2015
 * OBJETIVO     : Tela VALBOL
 * --------------
 * ALTERACOES   :
 * --------------
 */

var nrCharsAnt = 0;
var ajax = "";
var aux_dstpdpag = "titulo";

// Funcao para validar digitacao de numeros
function validaNumero(e) {
    var keyValue = 0;

    if (window.Event) {
        keyValue = e.which;   // Mozilla
    } else {
        keyValue = e.keyCode; // IE
    }

    if ((keyValue >= 48 && keyValue <= 57) || (keyValue == 8) || keyValue == 0) {
        return true;
    }

    return false;
}

// Funcao para aplicar formato a determinada parte da linha digitavel
function formataLinhaDigitavel(obj, objFoco, nrChars, char) {
    if (char != "" && nrChars > 0 && obj.value.length == nrChars && nrCharsAnt < nrChars) {
        obj.value += char;
    }

    nrCharsAnt = obj.value.length;

    if (obj.value.length == obj.maxLength) {
        objFoco.focus();
    }

    return true;
}

// Funcao para setar foco no div do tipo de pagamento
function setaFocoOpcao(divFoco, form) {
    if (divFoco == "fatura") {
        $("#divFatura").show();
        $("#divTitulo").hide();
    } else if (divFoco == "titulo") {
        $("#divTitulo").show();        
        $("#divFatura").hide();
    }

    aux_dstpdpag = divFoco;

    form.aux_lindigi1.focus();
}

// Funcao para validar formulario do fatura
function validaCamposFatura(form) {
    var msg = "";

    if (form.aux_cdbarras.disabled) {
        var obj = new Object();

        for (var field = 1; field <= 4; field++) {
            obj = eval("form.aux_lindigi" + field);

            if (obj.value == "") {
                msg = "Linha digitável inválida.";
            } else {
                if (obj.value.length != obj.maxLength) {
                    msg = "Linha digitável inválida.";
                } else {
                    for (i = 0; i < obj.value.length; i++) {
                        if (i == 11) {
                            if (obj.value.substr(i, 1) == "-") {
                                continue;
                            }
                            msg = "Linha digitável inválida.";
                            break;
                        }
                        if (isNaN(obj.value.substr(i, 1))) {
                            msg = "Linha digitável inválida.";
                            break;
                        }
                    }
                }
            }

            if (msg != "") {
                showError("error", "ATENÇÃO: " + msg, "Alerta - Ayllos", "$('#aux_lindigi"+ field+"', '#frmFatura').focus().val('');");  
                return false;
            }
        }
    } else if (form.aux_lindigi1.value == "") {
        if (!form.aux_lindigi1.disabled) {
            showError("error", "ATENÇÃO: Campos obrigatórios não foram preenchidos.", "Alerta - Ayllos", "$('#aux_lindigi1', '#frmFatura').focus();");
            form.aux_lindigi1.focus();            
            return false;
        }

        if (form.aux_cdbarras.value.length != form.aux_cdbarras.maxLength || isNaN(form.aux_cdbarras.value)) {
            showError("error", "ATENÇÃO: Código de barras incorreto.", "Alerta - Ayllos", "$('#aux_cdbarras', '#frmFatura').focus();");
            form.aux_cdbarras.focus();
            form.aux_cdbarras.value = "";
            return false;
        }
    }

    return true;
}

// Funcao para validar formulario do titulo
function validaCamposTitulo(form) {
    var msg = "";

    if (form.aux_cdbarras.disabled) {
        var obj = new Object();

        for (var field = 1; field <= 3; field++) {
            obj = eval("form.aux_lindigi" + field);

            if (obj.value == "") {
                msg = "Linha digitável inválida.";
            } else {
                if (obj.value.length != obj.maxLength) {
                    msg = "Linha digitavel inválida.";
                } else {
                    for (i = 0; i < obj.value.length; i++) {
                        if (i == 5) {
                            if (obj.value.substr(i, 1) == ".") {
                                continue;
                            }
                            msg = "Linha digitável inválida.";
                            break;
                        }
                        if (isNaN(obj.value.substr(i, 1))) {
                            msg = "Linha digitável inválida.";
                            break;
                        }
                    }
                }
            }
            if (msg != "") {
                showError("error", "ATENÇÃO: " + msg, "Alerta - Ayllos", "$('#aux_lindigi"+ field+"', '#frmTitulo').focus().val('');");
                return false;
            }
        }
        if (form.aux_lindigi4.value == "") {
            msg = "Linha digitável inválida.";
            obj = form.aux_lindigi4;
        } else if (form.aux_lindigi4.value.length != form.aux_lindigi4.maxLength) {
            msg = "Linha digitável inválida.";
            obj = form.aux_lindigi4;
        }
        if (msg != "") {
            showError("error", "ATENÇÃO: " + msg, "Alerta - Ayllos", "");
            obj.focus();            
            obj.value = "";
            return false;
        }
    } else {
        if (!form.aux_lindigi1.disabled) {
            showError("error", "ATENÇÃO: Campos obrigatórios não foram preenchidos.", "Alerta - Ayllos", "$('#aux_lindigi1', '#frmTitulo').focus();");
            form.aux_lindigi1.focus();            
            return false;
        }
        if (form.aux_cdbarras.value.length != form.aux_cdbarras.maxLength || isNaN(form.aux_cdbarras.value)) {
            showError("error", "ATENÇÃO: Código de barras incorreto.", "Alerta - Ayllos", "$('#aux_cdbarras', '#frmTitulo').focus();");
            form.aux_cdbarras.focus();            
            form.aux_cdbarras.value = "";
            return false;
        }
    }
    return true;
}

// Funcao para limpar campos do formulario informado
function limparCampos(form, tipo) {
    form.aux_lindigi1.value = "";
    form.aux_lindigi2.value = "";
    form.aux_lindigi3.value = "";
    form.aux_lindigi4.value = "";
    form.aux_lindigi1.disabled = false;
    form.aux_lindigi2.disabled = false;
    form.aux_lindigi3.disabled = false;
    form.aux_lindigi4.disabled = false;

    if (tipo == "T") { // titulo
        form.aux_lindigi5.value = "";
        form.aux_dtvencto.value = "";
        form.aux_lindigi5.disabled = false;
    }
    
    form.aux_vlrdocum.value = "";
    form.aux_cdbarras.value = "";
    form.aux_cdbarras.disabled = false;
    form.aux_lindigi1.focus();
}

// Funcao para desabilitar determinados campos do formulario informado
function desabilitaCampos(tipo, tpRepNumerica, form) {
    
    if (tpRepNumerica == "LD") { // Linha Digitavel
        if (form.aux_lindigi1.value == "" && form.aux_lindigi2.value == "" &&
                form.aux_lindigi3.value == "" && form.aux_lindigi4.value == "") {
            if (tipo == "T" && form.aux_lindigi5.value != "") { // titulo
                form.aux_cdbarras.disabled = true;
                form.aux_cdbarras.value = "";
                
                return true;
            }

            form.aux_cdbarras.disabled = false;

            return false;
        } else {
            form.aux_cdbarras.disabled = true;
            form.aux_cdbarras.value = "";

            return true;
        }
    } else if (tpRepNumerica == "CB") { // Codigo de barras
        if (form.aux_cdbarras.value == "") {
            form.aux_lindigi1.disabled = false;
            form.aux_lindigi2.disabled = false;
            form.aux_lindigi3.disabled = false;
            form.aux_lindigi4.disabled = false;

            if (tipo == "T") { // titulo
                form.aux_lindigi5.disabled = false;
            }
        } else {
            
            form.aux_lindigi1.disabled = true;
            form.aux_lindigi2.disabled = true;
            form.aux_lindigi3.disabled = true;
            form.aux_lindigi4.disabled = true;
            form.aux_lindigi1.value = "";
            form.aux_lindigi2.value = "";
            form.aux_lindigi3.value = "";
            form.aux_lindigi4.value = "";

            if (tipo == "T") { // titulo
                form.aux_lindigi5.disabled = true;
                form.aux_lindigi5.value = "";

            }
        }
    }
}

// Funcao para validar titulo ou fatura com leitura feita por c�digo de barras
function onReadCodBarras(form, tipo) {
    if (form.aux_cdbarras.value.length == form.aux_cdbarras.maxLength) {
        valida_documento(form, tipo);
    }
}

// Funcao para validar titulo ou fatura
function valida_documento(form, tipo) {
    var params = "";

    if (tipo == "T") { // titulo
        if (!validaCamposTitulo(form)) {
            return false;
        }
    } else if (tipo == "F") { // Fatura
        if (!validaCamposFatura(form)) {
            return false;
        }
    } else {
        showError("error", "ATENÇÃO: Parâmetros incorretos.", "Alerta - Ayllos", "");
        return false;
    }

    // Monta string com parametros para envio pelo metodo POST
    params += "aux_dstpdpag=" + aux_dstpdpag;
    params += form.aux_cdbarras.disabled ? "&aux_lindigi1=" + form.aux_lindigi1.value : "&aux_lindigi1=0";
    params += form.aux_cdbarras.disabled ? "&aux_lindigi2=" + form.aux_lindigi2.value : "&aux_lindigi2=0";
    params += form.aux_cdbarras.disabled ? "&aux_lindigi3=" + form.aux_lindigi3.value : "&aux_lindigi3=0";
    params += form.aux_cdbarras.disabled ? "&aux_lindigi4=" + form.aux_lindigi4.value : "&aux_lindigi4=0";

    if (tipo == "T") { // Titulo
        params += form.aux_cdbarras.disabled ? "&aux_lindigi5=" + form.aux_lindigi5.value : "&aux_lindigi5=0";
    } else if (tipo == "F") { // Fatura
        params += "&aux_lindigi5=";
    }

    params += form.aux_cdbarras.disabled ? "&aux_cdbarras=" : "&aux_cdbarras=" + form.aux_cdbarras.value;

    try {
        showMsgAguardo("Aguarde, validando acesso...");                
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/valbol/valbol.ajax.php?" + params,
            dataType: "json",
            async: false,
            success: function(data) {
                if (data.erro == 'S') {
                    showError("error",data.msg, "Alerta - Ayllos", "ocultaMsgAguardo();");
                } else if (data.erro == 'N') {
                    if (data.rows > 0) {
                        $.each(data.records, function(i, item) {
                            if (tipo == "T") { // Titulo
                                frmTitulo.aux_vlrdocum.value = (item.vlrdocum);
                                frmTitulo.aux_dtvencto.value = (item.dtvencto);
                            } else if (tipo == "F") { // Fatura
                                frmFatura.aux_vlrdocum.value = (item.vlrdocum);
                            }
                        });
                    }
                    ocultaMsgAguardo();
                }
            }
        });
    } catch (e) {
        showError('error', 'N&atilde;o foi possível concluir a requisição.', 'Alerta - Ayllos', '');        
    }

    return true;
}



function ocultaMsgAguardo()
{
    var varHide = false;
    varHide = setTimeout('hideMsgAguardo();', 500);
}
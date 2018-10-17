/*!
 * FONTE        : limcrd.js
 * CRIAÇÃO      : Amasonas Borges vieira Junior(Supero)
 * DATA CRIAÇÃO : 19/02/2018
 * OBJETIVO     : Biblioteca de funções da tela LIMCRD
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
var waiting;
var registros;
var page;
var globalEdit;
var btnVoltar;
var btnConcluir;
var btnExcluir;
var btnOKPressed;
var tplimcrd;
$(document).ready(function () {
    // Estado Inicial da tela
    waiting = $("#waiting");
    btnVoltar = $("#btVoltar");
    btnConcluir = $("#btConcluir");
    btnExcluir  = $('#btnExcluir');
    btnVoltar.click(function (evt) {
        $("#content").hide();
        $(".hideable").hide();
        btnConcluir.hide();
        btnExcluir.hide();
        btnVoltar.hide();
        $("#cddotipo").removeAttr("disabled");
        $("#mainAdmCrd").removeAttr("disabled", true);
        $("#tplimcrd").removeAttr("disabled");
        btnOKPressed = false;
        $("#cddotipo").val("I").change();
        $("#content").fadeIn("slow");
    });
    btnOKPressed = false;
    btnConcluir.hide();
    btnExcluir.hide();
    $(".hideable").hide();
    $(".clickable").css("cursor", "pointer");
    $(".VLLIMCRD").setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");
    formataCabecalho();
    $("#cddotipo").css({width: 300});
    triggerBtnOK();
    waiting.hide();
    btnVoltar.hide();
    var opcoes = $("#mainAdmCrd").find('option');
    $("#tplimcrd").change(function() {
        var mainAdmCrd = $("#mainAdmCrd").val();
        $("#mainAdmCrd").find('option').remove();        
        for (var i = 0; i < opcoes.length; i++) {
            var $elem = $(opcoes[i]);
            if ($(this).val() == 1) {
                if ($elem.attr('tpAdm') == "2") {
                    $("#mainAdmCrd").append($elem);
                }
            } else {
                $("#mainAdmCrd").append($elem);
            }
        }

        $("#mainAdmCrd option").each(function () {
            if ($(this).css('display') != 'none') {
                $("#mainAdmCrd").val($(this).val());
                return false;
            }
        });
    });
});

function carregarFormulario() {
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/limcrd/form_cadastro_limite.php",
        data: {
            admcrd: $("#mainAdmCrd").val(),
            "tplimcrd": tplimcrd
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#cadastros").html(response);
        }
    });
}

function triggerBtnOK() {

    $(".tableform").hide();

    $("#btnOK").click(function (param) {
        if (btnOKPressed)
            return;
        btnOKPressed = true;
        $(".hideable").hide();
        btnVoltar.show();
        var opt = $("#cddotipo").val();
        if (opt == "I") {
			var madm = parseInt($("#mainAdmCrd").val());
            tplimcrd = $("#tplimcrd").val();
			if(madm > 10 && madm < 18){				
				$.post("busca_limites.php", {"action": "C", "admcrd": madm, "tplimcrd": tplimcrd}, function (resp) {					
					if(resp[0].totalregistros > 0){
						//alertaLinhaExistente
						showError("error",labels.alertaLinhaExistente , "Alerta - Aimaro", "");
						btVoltar.click();
					}else{
						carregarFormulario();
						$(".tableform").show();
						$(".campoTelaSemBorda").removeAttr("readonly");
						$(".campoTelaSemBorda").removeAttr("disabled");//frmck
						$(".frmck").removeAttr("disabled");
						btnExcluir.hide();
						btnConcluir.show();
						globalEdit = true;
					}
				});
			}else{
				
				carregarFormulario();
				$(".tableform").show();
				$(".campoTelaSemBorda").removeAttr("readonly");
				$(".campoTelaSemBorda").removeAttr("disabled");//frmck
				$(".frmck").removeAttr("disabled");
				btnExcluir.hide();
				btnConcluir.show();
				globalEdit = true;
			}
			
            
        }
        else if (opt == "C") 
        {
            btnExcluir.hide();
            $(".campoTelaSemBorda").attr("readonly", true);
            $(".campoTelaSemBorda").attr("disabled", true);
            $(".frmck").attr("disabled", true);
            $(".frmck").attr("readonly", true);
            globalEdit = false;
            getLimites(false);
        } else if (opt == "A") {
            globalEdit = true;
            btnExcluir.hide();
            getLimites(true);
        }else if(opt == "E"){
            globalEdit = false;
            $(".campoTelaSemBorda").attr("readonly", true);
            $(".campoTelaSemBorda").attr("disabled", true);
            $(".frmck").attr("disabled", true);
            $(".frmck").attr("readonly", true);
            globalEdit = false;
            btnExcluir.show();
            getLimites(false);
        }
        $(".clickable").css("cursor", "pointer");
        $("#cddotipo").attr("disabled", true);
        $("#mainAdmCrd").attr("disabled", true);
        $("#tplimcrd").attr("disabled", true);

    });
}


function getLimites(edit) {
    page = 0;
    globalEdit = edit;
    waiting.show();
    admcrd = $('#mainAdmCrd').val();
    tplimcrd = $("#tplimcrd").val();
    $(".rls").remove();
    $.post("busca_limites.php", {"action": "C", "admcrd": admcrd, "tplimcrd": tplimcrd}, function (resp) {
        gerenciarResultados(resp, globalEdit);
    });
}

function gerenciarResultados(resp, edit) {
    registros = [];
    waiting.hide();
    $(".navbtn").show();
    updatePageStr(resp.length - 1);
    if ((resp.length - 1) < 50) {
        $(".paginacaoProx").hide();
    } else {
        $(".paginacaoProx").show();
    }
    //console.log(resp);
    $.each(resp, function (i, data) {
        if (i == 0) {
            return;
        }
        registros[i] = data;
        if (data.CDADMCRD == null)
            return;
        $("#registros").append(buildRow(data, i, globalEdit));
    })
    buildHeader();
    $("#registrosDiv").show();
    $("#registros").show();

}

function buildHeader() {
    admcrd = $('#mainAdmCrd').val();
    var header = $("#headertable");
    header.empty();
    if ((admcrd > 9) && (admcrd < 81)) {
        header.append('<th id="admCell" class=" admCell">' + labels.administradora + '</th>');
        header.append('<th id="limCell" class=" limCell">' + labels.limiteMin + '</th>');
        header.append('<th id="limiteCell" class=" limiteCell">' + labels.limiteMax + '</th>');
        header.append('<th id="diadebitoCell" class=" diadebitoCell">' + labels.diasDBT + '</th>');
    } else {
        header.append('<th id="admCell" class=" admCell" style=\'width: 164;\'>' + labels.administradora + '</th>');
        header.append('<th id="limCell" class=" limCell" style=\'width: 72;\'>' + labels.limite + '</th>');
        header.append('<th id="diadebitoCell" class=" diadebitoCell" style=\'width: 127;\'>' + labels.diasDBT + '</th>');
        header.append('<th id="limCell" class=" limCell" style=\'width: 60;\' >' + labels.codLimite + '</th>');
        header.append('<th id="limiteCell" class=" limiteCell">' + labels.ctaMae + '</th>');
    }
}

function pagination(movement) {
    if (movement == "fow")
        page++;
    else {
        if (page > 1)
            page--;
        else
            page = 0;
    }
    if (page == 0)
        $("#bkbtn").hide();
    else
        $("#bkbtn").show();
    $("#registrosDiv").hide();
    $("#registros").hide();
    waiting.show();
    $(".rls").remove();
    admcrd = $('#mainAdmCrd').val();
    tplimcrd = $("#tplimcrd").val();
    $.post("busca_limites.php", {"action": "C", "page": page, "admcrd": admcrd, "tplimcrd": tplimcrd}, function (resp) {
        gerenciarResultados(resp, globalEdit);
    });
}

function editarLimite(index, edit) {
    $("#btnExcluir").attr("index",index);
    tplimcrd = $("#tplimcrd").val();
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/limcrd/form_cadastro_limite.php",
        data: {
            admcrd: $("#mainAdmCrd").val(),
            "tplimcrd": tplimcrd
        },
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            $("#cadastros").html("");
            $("#cadastros").html(response);

            admcrd = $('#mainAdmCrd').val();
            var obj = registros[index];
            console.log(obj);
            if ((admcrd > 9) && (admcrd < 81)) {
                $("#vllimite_min").val(obj.vllimite_minimo);
                $("#vllimite_max").val(obj.vllimite_maximo);
                var diasDbt = obj.dsdias_debito.split(",");
                diasDbt.forEach(function (dia) {
                    console.log(dia);
                    $("input[value='" + dia + "']").attr("checked", true);
                });
                btnConcluir.show();
            } else {

                $("#CDADMCRD").val(obj.cdlimcrd);
                $("#NRCTAMAE").val(obj.nrctamae);
                $("#cdlimcrd").val(obj.cdlimcrd);
                $("#VLLIMCRD").val(obj.vllimite_maximo);
                var diasDbt = obj.dsdias_debito.split(",");
                $("#DDDEBITO").val(obj.dsdias_debito);
                $("#tpcartao").val(obj.tpcartao);
                $(".rls").removeClass("corSelecao");
                $("#linha" + index).addClass("corSelecao");
                $(".tableform").show();
            }
            if (!edit) {
                $(".campoTelaSemBorda").attr("readonly", true);
                $(".campoTelaSemBorda").attr("disabled", true);
                $(".frmck").attr("disabled", true);
                $(".frmck").attr("readonly", true);
                btnConcluir.hide();

            } else {
                $(".campoTelaSemBorda").removeAttr("readonly");
                $(".campoTelaSemBorda").removeAttr("disabled");
                $(".frmck").removeAttr("disabled");
                $(".frmck").removeAttr("readonly");
                btnConcluir.show();
            }

        }
    });


}

function buildRow(data, i, edit) {
    admcrd = $('#mainAdmCrd').val();

    if ((admcrd > 9) && (admcrd < 81)) {
        return "<tr class=\"rls " + "clickable" + "  "
            + (i % 2 == 0 ? " odd corPar" : " even corImpar") + " \" id=\"linha" + i + "\" onclick=\""
            + "editarLimite(" + i + "," + edit + ")" + "\">"
            + "<td class='admCell' style='width: 197px;'>" + $('#mainAdmCrd option:selected').text() + "</td>"
            + "<td class='limCell' style='width: 181px;'>" + data.vllimite_minimo + "</td>"
            + "<td class='limiteCell' style='width: 187px;'>" + data.vllimite_maximo + "</td>"
            + "<td class='diadebitoCell'>" + data.dsdias_debito + "</td>"
            + "</tr>";
    }
    return "<tr class=\"rls " + "clickable" + "  "
        + (i % 2 == 0 ? " odd corPar" : " even corImpar") + " \" id=\"linha" + i + "\" onclick=\""
        + "editarLimite(" + i + "," + edit + ")" + "\">"
        + "<td class='admCell' style='width: 164px;'>" + $('#mainAdmCrd option:selected').text() + "</td>"
        + "<td class='limiteCell' style='width: 72px;'>" + data.vllimite_maximo + "</td>"
        + "<td class='diadebitoCell' style='width: 127px;'>" + data.dsdias_debito + "</td>"
        + "<td class='tipocell' style='width: 60;'>" + data.cdlimcrd + "</td>"
        + "<td class='nrctamaecell'>" + data.nrctamae + "</td></tr>";
}


function formataCabecalho() {

    $('label[for="cddotipo"]', "#frmCab").addClass("rotulo").css({"width": "100px"});
    $("#cddotipo", "#frmCab").css("width", "500px").habilitaCampo();
    $('input[type="text"],select', '#frmCab').limpaFormulario().removeClass('campoErro');
    layoutPadrao();

    return false;
}

function updatePageStr(total) {
    $("#pageStr").html(page + 1);
}

function salvarLimite() {
    var cdadmcrd = $("#mainAdmCrd").val();
    var vllimite_min = $("#vllimite_min").val();
    var vllimite_max = $("#vllimite_max").val();
    var VLLIMCRD = $("#VLLIMCRD").val();
    var vllimite = $("#VLLIMCRD").val();
    var cdlimcrd = $("#cdlimcrd").val();
    var nrctamae = $("#NRCTAMAE").val();
    var insittab = $("#insittab").val();
    var tpcartao = $("#TPCARTAO").val();
    var dddebito = "";
    tplimcrd = $("#tplimcrd").val();

    var objToSend = {};
    objToSend.tplimcrd = tplimcrd;
    if ((cdadmcrd > 9) && (cdadmcrd < 81)) {
        $(".DDDEBITO").each(function (key, elem) {
            if (elem.checked) {
                dddebito += (elem.value) + ",";
            }
        })
        objToSend.cdadmcrd = cdadmcrd;
        objToSend.vllimite_min = vllimite_min;
        objToSend.vllimite_max = vllimite_max;
        objToSend.dddebito = dddebito.substring(0, dddebito.length - 1);
    } else {

        objToSend.cdadmcrd = cdadmcrd;
        objToSend.vllimite = VLLIMCRD;
        objToSend.nrctamae = nrctamae;
        objToSend.cdlimcrd = cdlimcrd;
        objToSend.insittab = $("#insittab").val();
        objToSend.tpcartao = $("#tpcartao").val();
       // objToSend.dddebito = $("input[id=DDDEBITO]:checked").val();
        objToSend.dddebito = $("#DDDEBITO").val();
    }
    if (objToSend.dddebito == undefined) {

    }
    objToSend.tpproces = "A";
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/limcrd/cadastro_limite.php",
        data: objToSend,
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            console.log(response);
            success = false;
            eval(response);
            if(success){
                showError("Alert", message, "Alerta - Aimaro", "");
                btnVoltar.click();
            }
            
        }
    });
}

function excluirLimite(){
    var index = $("#btnExcluir").attr("index");
    showMsgAguardo("Aguarde, Excluindo registro.");
    $("#btnExcluir").removeAttr("index");
    console.log("Excluido "+registros[index]);

    var cdadmcrd = $("#mainAdmCrd").val();
    var vllimite_min = $("#vllimite_min").val();
    var vllimite_max = $("#vllimite_max").val();
    var VLLIMCRD = $("#VLLIMCRD").val();
    var vllimite = $("#VLLIMCRD").val();
    var cdlimcrd = $("#cdlimcrd").val();
    var nrctamae = $("#NRCTAMAE").val();
    var insittab = $("#insittab").val();
    var tpcartao = registros[index].tpcartao;
    var dddebito = "";
    tplimcrd = $("#tplimcrd").val();

    var objToSend = {};
    objToSend.tplimcrd = tplimcrd;
    if ((cdadmcrd > 9) && (cdadmcrd < 81)) {
        $(".DDDEBITO").each(function (key, elem) {
            if (elem.checked) {
                dddebito += (elem.value) + ",";
            }
        })
        objToSend.cdadmcrd = cdadmcrd;
        objToSend.vllimite_min = vllimite_min;
        objToSend.vllimite_max = vllimite_max;
        objToSend.dddebito = dddebito.substring(0, dddebito.length - 1);
    } else {

        objToSend.cdadmcrd = cdadmcrd;
        objToSend.vllimite = VLLIMCRD;
        objToSend.nrctamae = nrctamae;
        objToSend.tpcartao = tpcartao;
        objToSend.cdlimcrd = cdlimcrd;
        objToSend.insittab = $("#insittab").val();

       // objToSend.dddebito = $("input[id=DDDEBITO]:checked").val();
        objToSend.dddebito = $("#DDDEBITO").val();
    }
    if (objToSend.dddebito == undefined) {

    }
    objToSend.tpproces = "E";
    $.ajax({
        type: "POST",
        dataType: "html",
        url: UrlSite + "telas/limcrd/cadastro_limite.php",
        data: objToSend,
        error: function (objAjax, responseError, objExcept) {

            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Aimaro", "blockBackground(parseInt($('#divRotina').css('z-index')))");
        },
        success: function (response) {
            console.log(response);
            success = false;
            eval(response);
            if(success){
                showError("Alert", message, "Alerta - Aimaro", "");
                btnVoltar.click();
            }
            
        }
    });
}
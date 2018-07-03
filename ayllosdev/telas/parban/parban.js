/*!
 * FONTE        : parban.js
 * CRIAÇÃO      : Gustavo Meyer
 * DATA CRIAÇÃO : 26/02/2017
 * OBJETIVO     : Biblioteca de funções da tela PARBAN
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */

//Titulo.php
var cddopcao;
var cdcanal;
var cdorigem_mensagem;
var cdmotivo_mensagem;

var idacao_banner;
var dstitulo_banner;
var insituacao_banner;

var cdtipo_mensagem;
var dsmensagem_acao_banner;
var inexibe_msg_confirmacao

//Imagem - banner_detalhamento.php
var nmimagem_banner;

//Botao acao - botao_acao.php
var inacao_banner;
var dslink_acao_banner;
var cdmenu_acao_mobile;

//Exibir para - exibir_quando.php
var dsfiltro_tipos_conta;
var tpfiltro;
var dsfiltro_cooperativas;
var dsfiltro_tipos_conta;

//Exibir quando - exibir_quando.php
var inexibir_quando;
var dtexibir_de;
var dtexibir_ate;
var tpfiltro_mobile;
var nmarquivo_csv;
var cdmensagem;

//Consulta.php
var attributeKey = "key";
var attributeCanelKey = "canalKey";
var attributeIndex = "index";
var sortableElem;
var cdBannerKeySelected;
var cdCanalKeySelected
var bannerName;

$(document).ready(function() {
    estadoInicial();
});

function estadoInicial() {
    $("#btnVoltar").hide();
    $("#btnSalvar").hide();
    $("#divConteudoConsulta").hide();
    $("#cdmotivo_mensagem").prop('disabled', true);
    $("#btnOK").show();
    $("#cddopcao").prop('disabled', false);
	$("#cdcanal").prop('disabled', false);
    $("#divConteudo").empty();
    layoutPadrao();
}

function escolheOpcao(par_cddopcao, par_cdcanal) {
    cddopcao = par_cddopcao;
	cdcanal = par_cdcanal;
    if (cddopcao == "I" || cddopcao == "CM") {
        $("#divConteudo").empty();
    }

    $("#btnOK").hide();
    $("#cddopcao").prop('disabled', true);
	$("#cdcanal").prop('disabled', true);
    $("#btnVoltar").show();

    if (cddopcao == "CM" || cddopcao == "I") {
        $("#btnSalvar").show();
    }

    // Executa script de exclusao de mensagens através de ajax
    $.ajax({
        type: "POST",
        url: "carrega_layout.php",
        data: {
            cddopcao: cddopcao,
			cdcanal: cdcanal,
            redirect: "script_ajax"
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
        },
        success: function(response) {
            try {
                $("#divConteudo").append(response);
                layoutPadrao();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
            }
        }
    });

    return false;

}

function voltar() {
    var divRegistro = $('div.divRegistros');
	
    if ($("#divConteudoConsulta").is(':visible')) {
        $("#btnSalvar").hide();
        $("#divConteudoConsulta").hide();
    } else {
        estadoInicial();
    }
}

function carregaImagem(tipoImg) {

    var extn = "";
    var imgPath = "";
    var image_holder = $("#divNmimagem_banner");

    if (tipoImg == 0) {
        imgPath = $("#dirimagem_banner")[0].value;
    } else {
        imgPath = $("#urlimagem_banner").val();
    }

    extn = imgPath.substring(imgPath.lastIndexOf('.') + 1).toLowerCase();
    $("#nmimagem_banner").val(imgPath.substring(imgPath.lastIndexOf('/') + 1).toLowerCase());
    $("#nmimagem_banner").val(imgPath.substring(imgPath.lastIndexOf('\\') + 1).toLowerCase());

    if (extn == "gif" || extn == "png" || extn == "jpg" || extn == "jpeg") {

        if (tipoImg == 0) {
            if (typeof(FileReader) != "undefined") {

                image_holder.empty();

                var reader = new FileReader();
                reader.onload = function(e) {

                    $("<img />", {
                        "src": e.target.result,
                        "class": "thumb-image",
                        "height": "178.25px",
                        "width": "310px"
                    }).appendTo(image_holder);

                }
                image_holder.show();
                reader.readAsDataURL($("#dirimagem_banner")[0].files[0]);

            } else {
                image_holder.empty();
                image_holder.html('<div style="padding:20px; text-align: center;"><b>IMAGEM ALTERADA</b><br/><br/> Para visualizar a imagem em tempo real utilize os navegadores IE 10+, Google Chrome 7+, Firefox 3.6+ ou Safari 6+</div>');
            }
        } else {
            image_holder.empty();
            $("<img />", { "src": imgPath, "class": "thumb-image", "height": "178.25px", "width": "310px" }).appendTo(image_holder);
        }
    } else {
        image_holder.empty();
        image_holder.html("<div style='padding-top:90px; text-align: center;'><b>IMAGEM N&Atilde;O CARREGADA</b></div>");
    }
}

function exibeAcao() {

    if ($('#inacao_banner').is(':checked')) {
        $('#divBtnAcaoConteudo').show();
    } else {
        $('#divBtnAcaoConteudo').hide();
    }
}

function acaoRadio(cdRaio, cdmenu_acao_mobile) {

    idacao_banner = cdRaio;

    if (cdRaio == 1) {
        $("#idacao_banner_url").attr('checked', 'checked');
        $("#cdmenu_acao_mobile").val("0");
        $('#cdmenu_acao_mobile').prop('disabled', true);
        $('#dslink_acao_banner').prop('disabled', false);
    } else {
        $("#idacao_banner_tela").attr('checked', 'checked');
        $('#dslink_acao_banner').val("");
        $('#dslink_acao_banner').prop('disabled', true);
        $('#cdmenu_acao_mobile').prop('disabled', false);
        $('#cdmenu_acao_mobile').val(cdmenu_acao_mobile);
    }
}

function acaoBotaoExibirQuandoRadio(cdRadio, dtExibirDe, dtExibirAte){
    inexibir_quando = cdRadio;

    if (cdRadio == 0) {
        $("#inexibir_quando_sem_expiracao").attr('checked', 'checked');

        $("#dtexibir_de").datepicker('disable');
        $("#dtexibir_ate").datepicker('disable');

        $("#dtexibir_de").val("");
        $("#dtexibir_ate").val("");
    } else {
        $("#inexibir_quando_periodo_valido").attr('checked', 'checked');
        
        $("#dtexibir_de").datepicker('enable');
        $("#dtexibir_ate").datepicker('enable');

        $("#dtexibir_de").val(dtExibirDe);
        $("#dtexibir_ate").val(dtExibirAte);
    }
}

function msgAcaoMobile(msgAcao) {

    if ($('#inexibe_msg_confirmacao').is(':checked')) {
        $('#dsmensagem_acao_banner').prop('disabled', false);
        $('#dsmensagem_acao_banner').val(msgAcao);
    } else {
        $('#dsmensagem_acao_banner').val(msgAcao);
        $('#dsmensagem_acao_banner').prop('disabled', true);
    }
}

function defineTempoDeTransicao(tempo) {

    if ($('#chk_nrsegundos_transicao').is(':checked')) {
        $('#nrsegundos_transicao').prop('disabled', false);
        $('#nrsegundos_transicao').val(tempo);
    } else {
        $('#nrsegundos_transicao').val(tempo);
        $('#nrsegundos_transicao').prop('disabled', true);
    }
}

function validaDados() {

    var flgerror = false;
    var dscritic = "";

    //VALIDA OS CAMPOS OBRIGATÓRIOS
    if (dstitulo_banner == "") {
        dscritic = "T&iacute;tulo &eacute; obrigat&oacute;rio";
        flgerror = true;
    } else if ($('#nmimagem_banner').val() == ""){
        dscritic = "Selecione uma imagem para o banner";
       flgerror = true;
    } else if (inacao_banner == 1) {
        if (idacao_banner == 1 && dslink_acao_banner == "") {
            dscritic = "URL do bot&atilde;o de a&ccedil;&atilde;o &eacute; obrigat&oacute;rio";
            flgerror = true;
        } else if (idacao_banner == 2 && cdmenu_acao_mobile == "") {
            dscritic = "Tela do Ailos Mobile do bot&atilde;o de a&ccedil;&atilde;o &eacute; obrigat&oacute;ria";
            flgerror = true;
        }
    } else if (inexibir_quando == 1) {
        if (dtexibir_de == "") {
            dscritic = "Data exibir de &eacute; obrigat&oacute;ria";
            flgerror = true;
        } else if (dtexibir_ate == "") {
            dscritic = "Data exibir at&eacute &eacute; obrigat&oacute;ria";
            flgerror = true;
        } 
    } 

    if (flgerror) {
        showError("error", dscritic, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
        return false;
    }

    return true;
}
function salvar() {

    //TITULO
    cdtipo_mensagem = $("#cdtipo_mensagem").val();
    dstitulo_banner = $("#dstitulo_banner").val();
    insituacao_banner = $("#insituacao_banner").val();
    inenviar_push = $("#inenviar_push").val();

    //BANNER DETALHAMENTO
    nmimagem_banner = $("#nmimagem_banner").val();

    //BOTAO ACAO
    if ($('#inacao_banner').is(':checked')) { inacao_banner = 1; } else { inacao_banner = 0; }
    //idacao_banner
    dslink_acao_banner = $("#dslink_acao_banner").val();
    cdmenu_acao_mobile = $("#cdmenu_acao_mobile").val();
    if ($('#inexibe_msg_confirmacao').is(':checked')) { dsmensagem_acao_mobile = $("#dsmensagem_acao_mobile").val(); } else { dsmensagem_acao_mobile = ""; }

    if (cddopcao == "I" || cddopcao == "CM") {

        tpfiltro = $("#tpfiltro").val();
        if (tpfiltro == 0) {
            dsfiltro_cooperativas = $("#dsfiltro_cooperativas").val();

            dsfiltro_tipos_conta = "";

            if ($("#dsfiltro_tipos_conta_fis").is(':checked')) {
                dsfiltro_tipos_conta = "1";
            }

            if ($("#dsfiltro_tipos_conta_jur").is(':checked')) {
                if (dsfiltro_tipos_conta == "") {
                    dsfiltro_tipos_conta = "2";
                } else {
                    dsfiltro_tipos_conta = dsfiltro_tipos_conta + ",2";
                }
            }

            for (var i = 0; i <= 2; i++) {
                if ($('#tpfiltro_mobile_' + i).is(':checked')) {
                    tpfiltro_mobile = i;
                }
            }
        } else {
            nmarquivo_csv = $("#nmarquivo_csv").val();
        }

        dtexibir_de = $("#dtexibir_de").val();
        dtexibir_ate = $("#dtexibir_ate").val();
    }

    if (!validaDados()) {
        return false;
    }

    showMsgAguardo("Aguarde, salvando informa&ccedil;&otilde;es...");
    $('#frmNovaMsg').append('<input type="hidden" id="sidlogin" name="sidlogin" />');
    $('#sidlogin', '#frmNovaMsg').val($('#sidlogin', '#frmMenu').val());

    var NavVersion = CheckNavigator();

    if (cddopcao == "I" || cddopcao == "CM") {

        action = 'upload_banner.php?keylink=' + milisegundos();

        // Configuro o formulário para posteriormente submete-lo
        $('#frmBanner').attr('method', 'post');
        $('#frmBanner').attr('action', action);
        $('#frmBanner').attr("target", 'frameBlank');
        $('#divListErr').html('');
		
        $('#frmBanner').submit();
    } 
}

function carregaEnviar(tpfiltro) {

    $("#divFile").hide();
    $("#divCooperativas").hide();

    if (tpfiltro == "" || tpfiltro == undefined) {
        tpfiltro = 0;
    }

    if (tpfiltro == 0) {
        $("#divCooperativas").show();
    } else if (tpfiltro == 1) {
        $("#divFile").show();
    }

}

function carregaConsulta(cdBanner, cdCanal) {

    cddopcao = "CM";

    // Executa script de exclusao de mensagens através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/parban/carrega_layout.php",
        data: {
            cddopcao: cddopcao,
            cdbanner: cdBanner,
            cdcanal: cdCanal,
            redirect: "script_ajax"
        },
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
        },
        success: function(response) {
            try {
                $("#divConteudoConsulta").show();
                $("#divConteudoConsulta").empty();
                $("#divConteudoConsulta").append(response);
                layoutPadrao();
				$("#btnSalvar").show();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
            }
        }
    });

    return false;
}

function excluirBanner() {
	showConfirmacao('Deseja excluir o item '+bannerName+'?', 
	'Confirma&ccedil;&atilde;o - Ayllos', 'excluirBannerAction()', 
	"hideMsgAguardo();", 'sim.gif', 'nao.gif');
}

function excluirBannerAction() {
    showMsgAguardo("Aguarde, removendo o banner...");
	
    var postMessage = {};
    postMessage.cdBanner = cdBannerKeySelected;
	postMessage.cdcanal = $("#cdcanal").val();
	postMessage.cdcooper = $("#hcdcooper").val();
	postMessage.cdagenci = $("#hcdagenci").val();
	postMessage.nrdcaixa = $("#hnrdcaixa").val();
	postMessage.idorigem = $("#hidorigem").val();
	postMessage.cdoperad = $("#hcdoperad").val();

    $.ajax({
        type: "POST",
        url: "remove_banner.php",
        data:postMessage,
        error: function(objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
        },
        success: function(response) {
            try {
				
                eval(response);
				
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
            }
        }
    });

    return false;
}
function removerBannerDaLista(){
	$('#banner'+cdBannerKeySelected+"",$('#grid_resultados')).remove();
	$("#divConteudoConsulta").empty();
	$("#btnSalvar").hide();
	$("btnExcluirBanner").hide();
}

function setGridSortable() {
	$("btnExcluirBanner").hide();
	
    elem = document.getElementById('grid_resultados');
    sortableElem = Sortable.create(elem, {
        group: 'grid_resultados',
        animation: 100,
        onUpdate: function (evt/**Event*/) {
            //updatePositionBtn").removeAttr("disabled");
			
        }	
    });

}

function selectItem(elem) {
    var jqElem = $(elem);
    $(".sortable").removeClass("selected");
    jqElem.addClass("selected");
    cdBannerKeySelected = jqElem.attr(attributeKey);
	cdCanalKeySelected = jqElem.attr(attributeCanelKey);
    bannerName = jqElem.context.innerText;
	$("btnExcluirBanner").show();
    carregaConsulta(cdBannerKeySelected,cdCanalKeySelected);
}

function undoGridSortable() {

    var state = sortableElem.option("disabled"); // get

    sortableElem.option("disabled", !state); // set

    $("#grid_resultados").css({"cursor": "wait"});
}

function updatePositions(btn) {
   
    if ($(btn).attr("disabled"))
        return;
    undoGridSortable();
    arrayParam = [];
    Array.from($(".sortable")).forEach(function (value, index) {
        obj = $(value).attr(attributeKey);
        arrayParam.push(obj);
    });
    var postMessage = {};
    postMessage.dsbannerorder = arrayParam.toString();
    postMessage.nrsegundos_transicao = $("#nrsegundos_transicao").val();
	postMessage.cdcanal = $("#cdcanal").val();
	postMessage.cdcooper = $("#hcdcooper").val();
	postMessage.cdagenci = $("#hcdagenci").val();
	postMessage.nrdcaixa = $("#hnrdcaixa").val();
	postMessage.idorigem = $("#hidorigem").val();
	postMessage.cdoperad = $("#hcdoperad").val();

	showMsgAguardo("Aguarde, salvando a ordena&ccedil;&atilde;o...");

    $.ajax({
        type: "POST",
        url: 'update_banner_header.php',
        data: postMessage,
        success: function (response) {
            setGridSortable();
			try {
                eval(response);
				hideMsgAguardo();
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message, "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
            }
        },
        error: function (XMLHttpRequest, textStatus, errorThrown) {
			showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "blockBackground(parseInt($('#divRotina').css('z-index')));hideMsgAguardo();");
        }
    });


}


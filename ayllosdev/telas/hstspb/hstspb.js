//************************************************************************//
//*** Fonte: logspb.js                                                 ***//
//*** Autor: David                                                     ***//
//*** Data : Novembro/2009                Última Alteração: 11/05/2017 ***//
//***                                                                  ***//
//*** Objetivo  : Biblioteca de funções da tela LOGSPB                 ***//
//***                                                                  ***//
//*** Alterações: 18/04/2012 - Criado a funcao controlaOperacao().     ***//
//***                          (Fabricio)                              ***//
//***             02/07/2012 - Alterado funcao obtemLog(), retirado ajax**//
//***                          imprimeLog(), alterado esquema para     ***//
//***                          impressao (Jorge)                       ***//
//***                                                                  ***//
//***             27/03/2013 - Alteração na padronização da tela para  ***//
//***                          novo layout (David Kruger).             ***//
//***                                                                  ***//
//***             18/11/2014 - Tratamento para a Incorporação Concredi ***//
//***                          e Credimilsul SD 223543 (Vanessa).      ***//
//***                                                                  ***//
//***             06/07/2015 - Inclusão do campo ISPB (Vanessa)        ***//
//***                                                                  ***//
//***             07/08/2015 - Gestão de TEDs/TECs - melhoria 85 (Lucas Ranghetti)
//***                                                                  ***//
//***             21/09/2015 - Adicionar para a cooperativa 16, a opção***//
//***                          "M" com a cooperativa VIACREDI          ***//
//***                          (Douglas - Chamado 288683)              ***//
//***                                                                  ***//
//***             09/11/2015 - Adicionar campo "Crise" no formulario de **//
//***                          consulta, opcao "L"                     ***//
//***                          (Jorge/Andrino)                         ***//
//***                                                                  ***//
//***             14/09/2016 - Adicionado validação do campo Sicredi    **//
//***                          e botões concluir e voltar              ***//
//***                          (Evandro - RKAM)                        ***//
//***                                                                  ***//
//***             07/11/2016 - Ajustes para corrigir problemas encontrados ***//
//***                          durante a homologação da área           ***//
//***                          (Adriano - M211)                        ***//
//***                                                                  ***//
//***             05/12/2016 - Incorporação Transulcred                ***//
//***                          (Guilherme/SUPERO)                      ***//
//***                                                                  ***//
//***             11/04/2017 - Permitir acessar o Ayllos mesmo vindo   ***//
//***                          do CRM. (Jaison/Andrino)				   ***//
//***                                                                  ***//
//***			  31/11/2017 - Ajustes para exibir TEDs estornadas		 ***//
//***			               devido a analise de fraude                ***//
//***			               PRJ335 - Analise de fraude(Odirlei-AMcom) ***//
//***                                                                    ***//
//***             11/05/2017 - Ajustes para a opção "Devoluções" do      ***//
//***                          campo "TIPO" (Douglas - Chamado 541233)   ***//
//                20/11/2018 - Alterar url de chamada ajax de logspb para hstspb
//                             Bruno Luiz Katzjarowski - Mout's  
//**************************************************************************//

var contWin = 0;
var detalhes = new Array();

var cdcooper;
var nmcooper;
var carregouOpcoes = false;

$(document).ready(function () {

    $('.Botoes').css("margin", "0 300px");
    $('.Botoes').css("cursor", "pointer");

    if (!carregouOpcoes)
        carregaOpcoes();

    // Seta os valores caso tenha vindo do CRM
    if ($("#crm_inacesso","#frmLogSPB").val() == 1) {
        $("#nrdconta","#frmLogSPB").val($("#crm_nrdconta","#frmLogSPB").val());
    }

    highlightObjFocus($('#frmLogSPB'));

    $("#cddopcao", "#frmLogSPB").bind("change", function (e) {

        if ($(this).val() == "R") {
            $("#divConteudoLog").css("display", "none");

            $("#flgidlog", "#frmLogSPB").val("2");
            $("#flgidlog", "#frmLogSPB").prop("disabled", true);

            $("#dtmvtlog", "#frmLogSPB").prop("disabled", false);

            $("#numedlog option:first", "#frmLogSPB").text("Todos");
            $("#numedlog option:first", "#frmLogSPB").val("0");
            $("#numedlog", "#frmLogSPB").val("0");
            $("#numedlog", "#frmLogSPB").prop("disabled", true);

            $("#cdsitlog option:first", "#frmLogSPB").text("Todas");
            $("#cdsitlog option:first", "#frmLogSPB").val("");
            $("#cdsitlog", "#frmLogSPB").val("");
            $("#cdsitlog", "#frmLogSPB").prop("disabled", true);

            $("#nrdconta", "#frmLogSPB").prop("disabled", true);
            $("#dsorigem", "#frmLogSPB").prop("disabled", true);
            $("#inestcri", "#frmLogSPB").prop("disabled", true);
            $("#vlrdated", "#frmLogSPB").prop("disabled", true);
            $("#divData", "#frmLogSPB").css("margin-left", "65px");

            $("#divCoop", "#frmLogSPB").hide();
            $("#divTipo", "#frmLogSPB").hide();
            $("#divLog", "#frmLogSPB").hide();
            $("#divContaOrigem", "#frmLogSPB").hide();
            $("#divData", "#frmLogSPB").show();

        } else if ($(this).val() == "L") {
            $("#flgidlog", "#frmLogSPB").prop("disabled", false);

            $("#dtmvtlog", "#frmLogSPB").prop("disabled", false);

            $("#numedlog option:first", "#frmLogSPB").text("Enviadas");
            $("#numedlog option:first", "#frmLogSPB").val("1");
            $("#numedlog", "#frmLogSPB").val("1");
            $("#numedlog", "#frmLogSPB").prop("disabled", false);

            $("#cdsitlog option:first", "#frmLogSPB").text("Processadas");
            $("#cdsitlog option:first", "#frmLogSPB").val("P");
            $("#cdsitlog", "#frmLogSPB").val("P");
            $("#cdsitlog", "#frmLogSPB").prop("disabled", false);

            $("#nrdconta", "#frmLogSPB").prop("disabled", false);
            $("#dsorigem", "#frmLogSPB").prop("disabled", false);
            $("#inestcri", "#frmLogSPB").prop("disabled", false);
            $("#vlrdated", "#frmLogSPB").prop("disabled", false);
            $("#divCoop", "#frmLogSPB").hide();
            $("#divTipo", "#frmLogSPB").show();
            $("#divLog", "#frmLogSPB").show();
            $("#divData", "#frmLogSPB").show();
            $("#divContaOrigem", "#frmLogSPB").show();
            $("#btImpCsv", "#frmLogSPB").hide();
            $("#btImpPsv", "#frmLogSPB").hide();

        } else { // opcao 'M'
            $("#divConteudoLog").css("display", "none");
            $("#flgidlog", "#frmLogSPB").prop("disabled", true);
            $("#dtmvtlog", "#frmLogSPB").prop("disabled", false);
            $("#numedlog", "#frmLogSPB").prop("disabled", true);
            $("#cdsitlog", "#frmLogSPB").prop("disabled", true);
            $("#nrdconta", "#frmLogSPB").prop("disabled", true);
            $("#dsorigem", "#frmLogSPB").prop("disabled", true);
            $("#inestcri", "#frmLogSPB").prop("disabled", true);
            $("#vlrdated", "#frmLogSPB").prop("disabled", true);
            $("#divData", "#frmLogSPB").css("margin-left", "65px");
            $("#divCoop", "#frmLogSPB").show();
            $("#divLog", "#frmLogSPB").hide();
            $("#divData", "#frmLogSPB").show();
            $("#divTipo", "#frmLogSPB").hide();
            $("#divContaOrigem", "#frmLogSPB").hide();
        }

        $("#flgidlog", "#frmLogSPB").trigger("change");
    });

    $("#flgidlog", "#frmLogSPB").bind("change", function (e) {
        var textSelect = new Array();
        var i = -1;

        if ($(this).val() == "1") {

            $("#cdsitlog", "#frmLogSPB").prop("disabled", true);
            $("#nrdconta", "#frmLogSPB").prop("disabled", true);
            $("#dsorigem", "#frmLogSPB").prop("disabled", true);

            textSelect[0] = "Todos";
            textSelect[1] = "Sucesso";
            textSelect[2] = "Erro";
        } else if ($("#cddopcao", "#frmLogSPB").val() != "M") {

            $("#cdsitlog", "#frmLogSPB").prop("disabled", false);
            $("#nrdconta", "#frmLogSPB").prop("disabled", false);
            $("#dsorigem", "#frmLogSPB").prop("disabled", false);

            textSelect[0] = "Enviadas";
            textSelect[1] = "Recebidas";
            textSelect[2] = "Devoluções";
            textSelect[3] = "Log";
            textSelect[4] = "Todos";
        }

        $("#numedlog option", "#frmLogSPB").each(function () {
            i++;

            $(this).text(textSelect[i]);
        });

        $("#numedlog", "#frmLogSPB").trigger("change");
    });

	$("#cdsitlog > #optProcessada", "#frmLogSPB").prop("disabled", false);
	$("#cdsitlog > #optDevolvida", "#frmLogSPB").prop("disabled", false);
	$("#cdsitlog > #optRejeitada", "#frmLogSPB").prop("disabled", false);
	$("#cdsitlog > #optEstornada", "#frmLogSPB").prop("disabled", false);
	$("#cdsitlog > #optTodas", "#frmLogSPB").prop("disabled", false);
	
    $("#numedlog", "#frmLogSPB").bind("change", function (e) {
        if ($("#cddopcao", "#frmLogSPB").val() == "R") {
            $("#cdsitlog", "#frmLogSPB").prop("disabled", true);
            $("#nrdconta", "#frmLogSPB").prop("disabled", true);
            $("#dsorigem", "#frmLogSPB").prop("disabled", true);
            $("#inestcri", "#frmLogSPB").prop("disabled", true);
            $("#vlrdated", "#frmLogSPB").prop("disabled", true);
        } else if ($("#cddopcao", "#frmLogSPB").val() == "L") {

            if ($("#flgidlog", "#frmLogSPB").val() == "1") {
                $("#cdsitlog", "#frmLogSPB").prop("disabled", true);
                $("#nrdconta", "#frmLogSPB").prop("disabled", true);
                $("#dsorigem", "#frmLogSPB").prop("disabled", true);
                $("#inestcri", "#frmLogSPB").prop("disabled", true);
                $("#vlrdated", "#frmLogSPB").prop("disabled", true);

                $("#numedlog option", "#frmLogSPB").each(function () {

                    $(this).prop("disabled", false);
                });

            } else {

                if ($("#flgidlog", "#frmLogSPB").val() == "3") {

                    $("#numedlog option", "#frmLogSPB").each(function () {
                        if ($(this).val() == "2") {
                            $(this).prop("disabled", false);
                            $(this).prop("selected", true);
                        }
                        else {
                            $(this).prop("disabled", true);
                        }
                    });

                } else {

                    $("#numedlog option", "#frmLogSPB").each(function () {

                        $(this).prop("disabled", false);
                    });

                }

                if ($(this).val() == "3") {
                    $("#cdsitlog", "#frmLogSPB").prop("disabled", true);
                    $("#nrdconta", "#frmLogSPB").prop("disabled", true);
                    $("#dsorigem", "#frmLogSPB").prop("disabled", true);
                    $("#inestcri", "#frmLogSPB").prop("disabled", true);
                    $("#vlrdated", "#frmLogSPB").prop("disabled", true);
                    $("#btImpCsv", "#frmLogSPB").hide();
                    $("#btImpPsv", "#frmLogSPB").hide();
                } else {
                    $("#cdsitlog", "#frmLogSPB").prop("disabled", false);
                    $("#nrdconta", "#frmLogSPB").prop("disabled", false);
                    $("#dsorigem", "#frmLogSPB").prop("disabled", false);
                    $("#inestcri", "#frmLogSPB").prop("disabled", false);
                    $("#vlrdated", "#frmLogSPB").prop("disabled", false);

                    $("#cdsitlog", "#frmLogSPB").val("P");

                    if ($(this).val() == "1") {
                        $("#cdsitlog > #optRejeitada", "#frmLogSPB").prop("disabled", false);
                        $("#cdsitlog > #optEstornada","#frmLogSPB").prop("disabled",false);
					// se for opcao todos habilita o estornadas
                    }else if ($(this).val() == "4") {
                        $("#cdsitlog > #optEstornada","#frmLogSPB").prop("disabled",false);
					//  se a opcao eh "devolucoes" 
					}else if ($(this).val() == "5") {
						$("#cdsitlog > #optProcessada", "#frmLogSPB").prop("disabled", true);
						$("#cdsitlog > #optDevolvida", "#frmLogSPB").prop("disabled", true);
						$("#cdsitlog > #optRejeitada", "#frmLogSPB").prop("disabled", true);
						$("#cdsitlog > #optEstornada", "#frmLogSPB").prop("disabled", true);
						
						$("#cdsitlog", "#frmLogSPB").val("T");
                    } else {
                        $("#cdsitlog > #optRejeitada", "#frmLogSPB").prop("disabled", true);
                        $("#cdsitlog > #optEstornada","#frmLogSPB").prop("disabled",true);
                        $("#btImpCsv", "#frmLogSPB").hide();
                        $("#btImpPsv", "#frmLogSPB").hide();
                    }
                }
            }
        } else { // opcao 'M'

        }
    });

    //Rótulos
    $('label[for="cddopcao"]', '#frmLogSPB').css({ 'width': '55px' });
    $('label[for="flgidlog"]', '#frmLogSPB').css({ 'width': '140px' });
    $('label[for="cdsitlog"]', '#frmLogSPB').css({ 'width': '140px' });
    $('label[for="dtmvtlog"]', '#frmLogSPB').css({ 'width': '75px' });
    $('label[for="numedlog"]', '#frmLogSPB').css({ 'width': '65px' });
    $('label[for="nrdconta"]', '#frmLogSPB').css({ 'width': '75px' });
    $('label[for="dsorigem"]', '#frmLogSPB').css({ 'width': '65px' });
    $('label[for="inestcri"]', '#frmLogSPB').css({ 'width': '140px' });
    $('label[for="vlrdated"]', '#frmLogSPB').css({ 'width': '75px' });

    //Campos
    $("#cddopcao", "#frmLogSPB").css({ 'width': '535px' });
    $("#flgidlog", "#frmLogSPB").css({ 'width': '120px' });
    $("#cdsitlog", "#frmLogSPB").css({ 'width': '120px' });
    $("#dtmvtlog", "#frmLogSPB").css({ 'width': '90px' });
    $("#numedlog", "#frmLogSPB").css({ 'width': '120px' });
    $("#nrdconta", "#frmLogSPB").css({ 'width': '90px' });
    $("#dsorigem", "#frmLogSPB").css({ 'width': '120px' });
    $("#inestcri", "#frmLogSPB").css({ 'width': '120px' });
    $("#vlrdated", "#frmLogSPB").css({ 'width': '90px' });

    controlaFoco();

    $("#dtmvtlog", "#frmLogSPB").setMask("DATE", "", "", "");
    $("#nrdconta", "#frmLogSPB").setMask("INTEGER", "zzzz.zzz-z", "", "");
    $("#vlrdated", "#frmLogSPB").setMask("DECIMAL", "zzz.zzz.zz9,99", "", "");

    $("#cddopcao", "#frmLogSPB").trigger("change");
    $("#flgidlog", "#frmLogSPB").trigger("change");

    $("#cddopcao", "#frmLogSPB").focus();
});

function VoltarLoad() {
    $("#divConteudoLog").css("display", "none");

    $("#flgidlog", "#frmLogSPB").prop("disabled", false);

    $("#dtmvtlog", "#frmLogSPB").prop("disabled", false);

    $("#numedlog option:first", "#frmLogSPB").text("Enviadas");
    $("#numedlog option:first", "#frmLogSPB").val("1");
    $("#numedlog", "#frmLogSPB").val("1");
    $("#numedlog", "#frmLogSPB").prop("disabled", false);

    $("#cdsitlog option:first", "#frmLogSPB").text("Processadas");
    $("#cdsitlog option:first", "#frmLogSPB").val("P");
    $("#cdsitlog", "#frmLogSPB").val("P");
    $("#cdsitlog", "#frmLogSPB").prop("disabled", false);

    $("#nrdconta", "#frmLogSPB").prop("disabled", false);
    $("#dsorigem", "#frmLogSPB").prop("disabled", false);
    $("#inestcri", "#frmLogSPB").prop("disabled", false);
    $("#vlrdated", "#frmLogSPB").prop("disabled", false);
    $("#divCoop", "#frmLogSPB").hide();
    $("#divTipo", "#frmLogSPB").show();
    $("#divLog", "#frmLogSPB").show();
    $("#divData", "#frmLogSPB").show();
    $("#divContaOrigem", "#frmLogSPB").show();
    $("#btImpCsv", "#frmLogSPB").hide();
    $("#btImpPsv", "#frmLogSPB").hide();
}

function controlaFoco() {

    var cddopcao = $('#cddopcao', '#frmLogSPB').val();

    if (cddopcao == 'L') {
        $('#cddopcao', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#flgidlog', '#frmLogSPB').focus();
                return false;
            }
        });

    } else {
        $('#cddopcao', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#dtmvtlog', '#frmLogSPB').focus();
                return false;
            }
        });
    }

    $('#flgidlog', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dtmvtlog', '#frmLogSPB').focus();
            return false;
        }
    });

    if (cddopcao == 'L') {
        $('#dtmvtlog', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#numedlog', '#frmLogSPB').focus();
                return false;
            }
        });

    } else {
        $('#dtmvtlog', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
            if (e.keyCode == 9 || e.keyCode == 13 || e.keyCode == 118) {
                obtemLog();
                return false;
            }
        });
    }

    $('#numedlog', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#cdsitlog', '#frmLogSPB').focus();
            return false;
        }

    });

    $('#cdsitlog', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#nrdconta', '#frmLogSPB').focus();
            return false;
        }

    });


    $('#nrdconta', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 9 || e.keyCode == 13) {
            $('#dsorigem', '#frmLogSPB').focus();
            return false;
        }

    });


    $('#dsorigem', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118) {
            $('#inestcri', '#frmLogSPB').focus();
            return false;
        }
    });

    $('#inestcri', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118) {
            $('#vlrdated', '#frmLogSPB').focus();
            return false;
        }
    });

    $('#vlrdated', '#frmLogSPB').unbind('keypress').bind('keypress', function (e) {
        if (e.keyCode == 13 || e.keyCode == 9 || e.keyCode == 118) {
            obtemLog();
            return false;
        }
    });

}


// Função para carregar log
function obtemLog() {

    if ($("#cddopcao", "#frmLogSPB").val() == "M") {
        obtemLogTedsMigradas();
    } else {

        $("#divDetalhesLog").css("display", "none");
        $("#divConteudoLog").css("display", "none");
        $("#divConteudoLog").html("&nbsp;");

        var sidlogin = $("#sidlogin", "#frmLogSPB").val();
        var cddopcao = $("#cddopcao", "#frmLogSPB").val();
        var flgidlog = $("#flgidlog", "#frmLogSPB").val();
        var dtmvtlog = $("#dtmvtlog", "#frmLogSPB").val();
        var numedlog = $("#numedlog", "#frmLogSPB").val();
        var cdsitlog = $("#cdsitlog", "#frmLogSPB").val();
        var nrdconta = retiraCaracteres($("#nrdconta", "#frmLogSPB").val(), "0123456789", true);
        var dsorigem = $("#dsorigem", "#frmLogSPB").val();
        var inestcri = $("#inestcri", "#frmLogSPB").val();
        var vlrdated = $("#vlrdated", "#frmLogSPB").val();

        // Se nenhum dos tipos de conta foi informado
        if (dtmvtlog == "") {
            showError("error", "Informe a data do log.", "Alerta - Ayllos", "$('#dtmvtlog','#frmLogSPB').focus()");
            return false;
        }

        if (cddopcao == "R" || flgidlog == "1" || ((flgidlog == "2" || flgidlog == "3") && numedlog == "3")) {

            imprimeLog("", sidlogin);

        } else {

            // Mostra mensagem de aguardo
            showMsgAguardo("Aguarde, carregando log de transa&ccedil;&otilde;es ...");

            // Carrega dados da conta através de ajax
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/hstspb/obtem_log_spb.php",
                data: {
                    flgidlog: flgidlog,
                    dtmvtlog: dtmvtlog,
                    numedlog: numedlog,
                    cdsitlog: cdsitlog,
                    nrdconta: nrdconta,
                    dsorigem: dsorigem,
                    nriniseq: 1,
                    nrregist: 50,
                    inestcri: inestcri,
                    vlrdated: vlrdated,
                    redirect: "script_ajax" // Tipo de retorno do ajax
                },
                error: function (objAjax, responseError, objExcept) {
                    hideMsgAguardo();
                    showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#flgidlog','#frmLogSPB').focus()");
                },
                success: function (response) {
                    try {
                        eval(response);
                    } catch (error) {
                        hideMsgAguardo();
                        showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#flgidlog','#frmLogSPB').focus()");
                    }
                }
            });
        }
    }
}

function selecionaMsgLog(id, tipo) {
    $("#dsmotivo", "#frmDetalheLog").val(detalhes[id].dsmotivo);
    $("#cdbanrem", "#frmDetalheLog").val(detalhes[id].cdbanrem);
    $("#cdispbrem", "#frmDetalheLog").val(detalhes[id].cdispbrem);
    $("#cdagerem", "#frmDetalheLog").val(detalhes[id].cdagerem);
    $("#nrctarem", "#frmDetalheLog").val(detalhes[id].nrctarem);
    $("#dsnomrem", "#frmDetalheLog").val(detalhes[id].dsnomrem);
    $("#dscpfrem", "#frmDetalheLog").val(detalhes[id].dscpfrem);
    $("#cdbandst", "#frmDetalheLog").val(detalhes[id].cdbandst);
    $("#cdispbdst", "#frmDetalheLog").val(detalhes[id].cdispbdst);
    $("#cdagedst", "#frmDetalheLog").val(detalhes[id].cdagedst);
    $("#nrctadst", "#frmDetalheLog").val(detalhes[id].nrctadst);
    $("#dsnomdst", "#frmDetalheLog").val(detalhes[id].dsnomdst);
    $("#dscpfdst", "#frmDetalheLog").val(detalhes[id].dscpfdst);
    $("#vltransa", "#frmDetalheLog").val(detalhes[id].vltransa);
    $("#dstransa", "#frmDetalheLog").val(detalhes[id].dstransa);
    $("#nmevento", "#frmDetalheLog").val(detalhes[id].nmevento);
    $("#nrctrlif", "#frmDetalheLog").val(detalhes[id].nrctrlif);
    $("#hrtransa", "#frmDetalheLog").val(detalhes[id].hrtransa);

    $("#divConteudoLog").css("display", "none");
    $("#divDetalhesLog").css("display", "block");

    if (tipo > 0) {
        $("#divCampoMotivo").css("display", "block");
    } else {
        $("#tdMotivoDetalhe").html("DETALHES:&nbsp;");
    }
}

function voltarDetalhes() {
    $("#divDetalhesLog").css("display", "none");
    $("#divConteudoLog").css("display", "block");
}

function controlaOperacao(nriniseq, nrregist) {

    var flgidlog = $("#flgidlog", "#frmLogSPB").val();
    var dtmvtlog = $("#dtmvtlog", "#frmLogSPB").val();
    var numedlog = $("#numedlog", "#frmLogSPB").val();
    var cdsitlog = $("#cdsitlog", "#frmLogSPB").val();
    var nrdconta = retiraCaracteres($("#nrdconta", "#frmLogSPB").val(), "0123456789", true);
    var dsorigem = $("#dsorigem", "#frmLogSPB").val();
    var inestcri = $("#inestcri", "#frmLogSPB").val();

    // Mostra mensagem de aguardo
    showMsgAguardo("Aguarde, carregando log de transa&ccedil;&otilde;es ...");

    // Carrega dados da conta através de ajax
    $.ajax({
        type: "POST",
        url: UrlSite + "telas/hstspb/obtem_log_spb.php",
        data: {
            flgidlog: flgidlog,
            dtmvtlog: dtmvtlog,
            numedlog: numedlog,
            cdsitlog: cdsitlog,
            nrdconta: nrdconta,
            dsorigem: dsorigem,
            nriniseq: nriniseq,
            nrregist: nrregist,
            inestcri: inestcri,
            redirect: "script_ajax" // Tipo de retorno do ajax
        },
        error: function (objAjax, responseError, objExcept) {
            hideMsgAguardo();
            showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#flgidlog','#frmLogSPB').focus()");
        },
        success: function (response) {
            try {
                eval(response);
            } catch (error) {
                hideMsgAguardo();
                showError("error", "N&atilde;o foi poss&iacute;vel concluir a requisi&ccedil;&atilde;o. " + error.message + ".", "Alerta - Ayllos", "$('#flgidlog','#frmLogSPB').focus()");
            }
        }
    });

}

function imprimeLog(nmarqpdf, sidlogin) {

    var sidlogin = $("#sidlogin", "#frmLogSPB").val();
    var cddopcao = $("#cddopcao", "#frmLogSPB").val();
    var flgidlog = $("#flgidlog", "#frmLogSPB").val();
    var dtmvtlog = $("#dtmvtlog", "#frmLogSPB").val();
    var numedlog = $("#numedlog", "#frmLogSPB").val();
    var cdsitlog = $("#cdsitlog", "#frmLogSPB").val();

    $('#frmImpressao').append('<input type="hidden" id="cddopcao" name="cddopcao" value="' + cddopcao + '" />');
    $('#frmImpressao').append('<input type="hidden" id="flgidlog" name="flgidlog" value="' + flgidlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="dtmvtlog" name="dtmvtlog" value="' + dtmvtlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="numedlog" name="numedlog" value="' + numedlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="cdsitlog" name="cdsitlog" value="' + cdsitlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="nmarqpdf" name="nmarqpdf" value="' + nmarqpdf + '" />');
    $('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + sidlogin + '" />');

    var action = UrlSite + "telas/hstspb/impressao_log_spb.php";

    carregaImpressaoAyllos("frmImpressao", action);

}

function carregaOpcoes() {

    if (cdcooper == 1 || cdcooper == 2 || cdcooper == 3 || cdcooper == 13 || cdcooper == 16 || cdcooper == 9) {
        $('#cddopcao', '#frmLogSPB').append("<option value='L' selected> L - Consultar o log das Teds</option>");
        $('#cddopcao', '#frmLogSPB').append("<option value='R'> R - Gerar relatório de transações SPB</option>");
        $('#cddopcao', '#frmLogSPB').append("<option value='M'> M - Gerar relatório de Teds migradas</option>");
    } else {
        $('#cddopcao', '#frmLogSPB').append("<option value='L' selected> L - Consultar o log das Teds</option>");
        $('#cddopcao', '#frmLogSPB').append("<option value='R'> R - Gerar relatório de transações SPB</option>");
    }

    if (cdcooper == 1) {
        $('#cdcopmig', '#frmLogSPB').append("<option value='2' selected> ACREDI</option>");
        $('#cdcopmig', '#frmLogSPB').append("<option value='4'>CONCREDI</option>");

    } else
        if (cdcooper == 3) {
            $('#cdcopmig', '#frmLogSPB').append("<option value='1' selected>VIACREDI</option>");
            $('#cdcopmig', '#frmLogSPB').append("<option value='2' >ACREDI</option>");
            $('#cdcopmig', '#frmLogSPB').append("<option value='4' >CONCREDI</option>");
            $('#cdcopmig', '#frmLogSPB').append("<option value='15'>CREDIMILSUL</option>");
            $('#cdcopmig', '#frmLogSPB').append("<option value='17'>TRANSULCRED</option>");
        } else
            if (cdcooper == 13) {
                $('#cdcopmig', '#frmLogSPB').append("<option value='15'>CREDIMILSUL</option>");

            } else
                if (cdcooper == 16) {
                    $('#cdcopmig', '#frmLogSPB').append("<option value='1'>VIACREDI</option>");
                }
                else{
                    if (cdcooper ==  9) {
                        $('#cdcopmig', '#frmLogSPB').append("<option value='17'>TRANSULCRED</option>");
                    }
                    else {
                        $('#cdcopmig', '#frmLogSPB').append("<option value='" + cdcooper + "'>" + nmcooper + "</option>");
                    }
                }

    carregouOpcoes = true;

}

function obtemLogTedsMigradas() {

    var sidlogin = $("#sidlogin", "#frmLogSPB").val();
    var datmigra = $("#dtmvtlog", "#frmLogSPB").val();
    var cdcopmig = $("#cdcopmig", "#frmLogSPB").val();
    var dscopmig = $('#cdcopmig :selected').text();

    $('#frmImpressao').append('<input type="hidden" id="datmigra" name="datmigra" value="' + datmigra + '" />');
    $('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + sidlogin + '" />');
    $('#frmImpressao').append('<input type="hidden" id="cdcopmig" name="cdcopmig" value="' + cdcopmig + '" />');
    $('#frmImpressao').append('<input type="hidden" id="dscopmig" name="dscopmig" value="' + dscopmig + '" />');

    var action = UrlSite + "telas/logspb/impressao_log_teds_migradas.php";

    carregaImpressaoAyllos("frmImpressao", action);

}

function ImprimirTodos(tipo) {
    if (tipo == 1) {
        showConfirmacao('Deseja exportar relat&oacute;rio?', 'Confirma&ccedil;&atilde;o - Ayllos', 'Csv();', 'bloqueiaFundo(divRotina);hideMsgAguardo();', 'sim.gif', 'nao.gif');
    } else {
        showConfirmacao('Deseja visualizar a impress&atilde;o?', 'Confirma&ccedil;&atilde;o - Ayllos', 'Pdf();', 'bloqueiaFundo(divRotina);hideMsgAguardo();', 'sim.gif', 'nao.gif');
    }
}

function Csv() {

    var cddopcao = $("#cddopcao", "#frmLogSPB").val();
    var sidlogin = $("#sidlogin", "#frmLogSPB").val();
    var flgidlog = $("#flgidlog", "#frmLogSPB").val();
    var dtmvtlog = $("#dtmvtlog", "#frmLogSPB").val();
    var numedlog = $("#numedlog", "#frmLogSPB").val();
    var cdsitlog = $("#cdsitlog", "#frmLogSPB").val();
    var nrdconta = $("#nrdconta", "#frmLogSPB").val();
    var dsorigem = $("#dsorigem", "#frmLogSPB").val();
    var inestcri = $("#inestcri", "#frmLogSPB").val();
    var vlrdated = $("#vlrdated", "#frmLogSPB").val();

    $('#frmImpressao').append('<input type="hidden" id="cddopcao" name="cddopcao" value="' + cddopcao + '" />');
    $('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + sidlogin + '" />');
    $('#frmImpressao').append('<input type="hidden" id="flgidlog" name="flgidlog" value="' + flgidlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="dtmvtlog" name="dtmvtlog" value="' + dtmvtlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="numedlog" name="numedlog" value="' + numedlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="cdsitlog" name="cdsitlog" value="' + cdsitlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" value="' + nrdconta + '" />');
    $('#frmImpressao').append('<input type="hidden" id="dsorigem" name="dsorigem" value="' + dsorigem + '" />');
    $('#frmImpressao').append('<input type="hidden" id="inestcri" name="inestcri" value="' + inestcri + '" />');
    $('#frmImpressao').append('<input type="hidden" id="vlrdated" name="vlrdated" value="' + vlrdated + '" />');

    var action = UrlSite + "telas/hstspb/impressao_log_csv.php";

    carregaImpressaoAyllos("frmImpressao", action);
}

function Pdf() {

    var cddopcao = $("#cddopcao", "#frmLogSPB").val();
    var sidlogin = $("#sidlogin", "#frmLogSPB").val();
    var flgidlog = $("#flgidlog", "#frmLogSPB").val();
    var dtmvtlog = $("#dtmvtlog", "#frmLogSPB").val();
    var numedlog = $("#numedlog", "#frmLogSPB").val();
    var cdsitlog = $("#cdsitlog", "#frmLogSPB").val();
    var nrdconta = $("#nrdconta", "#frmLogSPB").val();
    var dsorigem = $("#dsorigem", "#frmLogSPB").val();
    var inestcri = $("#inestcri", "#frmLogSPB").val();
    var vlrdated = $("#vlrdated", "#frmLogSPB").val();

    $('#frmImpressao').append('<input type="hidden" id="cddopcao" name="cddopcao" value="' + cddopcao + '" />');
    $('#frmImpressao').append('<input type="hidden" id="sidlogin" name="sidlogin" value="' + sidlogin + '" />');
    $('#frmImpressao').append('<input type="hidden" id="flgidlog" name="flgidlog" value="' + flgidlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="dtmvtlog" name="dtmvtlog" value="' + dtmvtlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="numedlog" name="numedlog" value="' + numedlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="cdsitlog" name="cdsitlog" value="' + cdsitlog + '" />');
    $('#frmImpressao').append('<input type="hidden" id="nrdconta" name="nrdconta" value="' + nrdconta + '" />');
    $('#frmImpressao').append('<input type="hidden" id="dsorigem" name="dsorigem" value="' + dsorigem + '" />');
    $('#frmImpressao').append('<input type="hidden" id="inestcri" name="inestcri" value="' + inestcri + '" />');
    $('#frmImpressao').append('<input type="hidden" id="vlrdated" name="vlrdated" value="' + vlrdated + '" />');

    var action = UrlSite + "telas/hstspb/impressao_log_pdf.php";

    carregaImpressaoAyllos("frmImpressao", action);


}
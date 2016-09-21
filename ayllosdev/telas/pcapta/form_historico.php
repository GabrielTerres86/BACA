<?php
/* !
 * FONTE        : form_historico.php
 * CRIAÇÃO      : Jean Michel         
 * DATA CRIAÇÃO : 30/04/2014
 * OBJETIVO     : Formulario de historico da tela PCAPTA
 * --------------
 * ALTERAÇÕES   : ????????????????????????????
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

setVarSession('nmrotina', 'HISTORICO');
?>
<div id="historicosDados">
    <fieldset>
        <legend>Hist&oacute;ricos</legend>
        <table>
            <tr>
                <td>
                    <label class="cdprodut" for="cdprodut">Produto:</label>
                    <select name="cdprodut" id="cdprodut">
                        <option value="0">-- Selecione --</option>
                    </select>
                </td>
            </tr>
        </table>
        <br />
        <fieldset>
            <legend>Conta Corrente</legend>
            <table>
                <tr>
                    <td>
                        <label for="cdhscacc">D&eacute;bito Aplica&ccedil;&atilde;o:</label>
                        <input type="text" name="cdhscacc" id="cdhscacc" value="" maxlength="4" class="inteiro" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="cdhsvrcc">Cr&eacute;dito Resgate/Vencimento Aplica&ccedil;&atilde;o:</label>
                        <input type="text" name="cdhsvrcc" id="cdhsvrcc" value="" maxlength="4" class="inteiro" />
                    </td>
                </tr>
            </table>
        </fieldset>

        <fieldset>
            <legend>Aplica&ccedil;&atilde;o</legend>
            <table>
                <tr>
                    <td>
                        <label for="cdhsraap">Cr&eacute;dito Renova&ccedil;&atilde;o Aplica&ccedil;&atilde;o:</label>
                        <input type="text" name="cdhsraap" id="cdhsraap" value="" maxlength="4" class="inteiro" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="cdhsnrap">Cr&eacute;dito Aplica&ccedil;&atilde;o Recurso Novo:</label>
                        <input type="text" name="cdhsnrap" id="cdhsnrap" value="" maxlength="4" class="inteiro" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="cdhsprap">Cr&eacute;dito Atualiza&ccedil;&atilde;o Juros:</label>
                        <input type="text" name="cdhsprap" id="cdhsprap" value="" maxlength="4" class="inteiro" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="cdhsrvap">D&eacute;bito Revers&atilde;o Atualiza&ccedil;&atilde;o Juros:</label>
                        <input type="text" name="cdhsrvap" id="cdhsrvap" value="" maxlength="4" class="inteiro" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="cdhsrdap">Cr&eacute;dito Rendimento:</label>
                        <input type="text" name="cdhsrdap" id="cdhsrdap" value="" maxlength="4" class="inteiro" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="cdhsirap">D&eacute;bito IRRF:</label>
                        <input type="text" name="cdhsirap" id="cdhsirap" value="" maxlength="4" class="inteiro" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="cdhsrgap">D&eacute;bito Resgate:</label>
                        <input type="text" name="cdhsrgap" id="cdhsrgap" value="" maxlength="4" class="inteiro" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <label for="cdhsvtap">D&eacute;bito Vecimento:</label>
                        <input type="text" name="cdhsvtap" id="cdhsvtap" value="" maxlength="4" class="inteiro" />
                    </td>
                </tr>
                <tr class="linhaBotoes">
                    <td>
                        <a href="javascript:void(0);" class="botao" id="btVoltar" name="btVoltar" onclick="resetaForm('historicosDados');">Voltar</a>
                        <a href="javascript:void(0);" class="botao" id="btProseg"  onclick="validaCadastro();">Prosseguir</a>
                        <input type="hidden" id="hdnProdSel" value="0" />
                    </td>
                </tr>
            </table>
        </fieldset>
    </fieldset>
    <table class="tableAcoes">
        <tr>
            <td>
                <input type="hidden" id="hdnAcao" value="" />
                <a href="javascript:void(0);" class="botao" id="btVoltar"  onclick="escolheOpcao('H', 'V');">Voltar</a>
                <a href="javascript:void(0);" class="botao" id="btAltera"  onclick="escolheOpcao('H', 'A');">Alterar</a>
                <a href="javascript:void(0);" class="botao" id="btConsul"  onclick="escolheOpcao('H', 'C');">Consultar</a>
            </td>
        </tr>
    </table>	
</div>
<style type="text/css">
    #historicosDados table td label {
        width: 250px;
    }

    label.cdprodut {
        width: 169px !important;
    }

    #cdprodut {
        width: 180px !important;
    }

    #btProseg {

    }

    fieldset table {
        margin-left: 20px;
    }
    table.tituloRegistros {
        margin-left: 0px !important;
    }
    #divPesquisaRodape table {
        margin-left: 0px !important;
    }

    table.tableAcoes {
        margin-left:160px;
        width: 360px;
    }

    .linhaBotoes {
        display: none;
        height: 30px;
        margin: 0 auto;
        width: 180px;
    }  

    fieldset table input {
        background-color: #FFFFFF;
        border: 1px solid #777777;
        color: #111111;
        font-size: 12px;
        height: 20px;
        padding: 2px 4px 1px;
        width: 90px;        
    }

</style>
<script>
    $(function() {
        
        var ua = window.navigator.userAgent;
        var msie = ua.indexOf ( "MSIE " );        
        
        $('#cdprodut', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                carregaDadosProduto($(this));
            }
        });

        $('#cdprodut', '#frmCab').unbind('click').bind('click', function() {
            carregaDadosProduto($(this));
        });


        /* NAVEGACAO PELOS CAMPOS */
        $('#cdhscacc', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                
                var retorno = validaCodigoHistorico($(this));

                if (retorno != '') {
                    showError("error", retorno, "Alerta - Ayllos", "$('#" + $(this).attr('id') + "', '#frmCab').focus();hideMsgAguardo();");
                } else {
                    hideMsgAguardo();
                    
                    //limpa o campo caso ele for zero
                    if ($('#cdhsvrcc', '#frmCab').val() == 0) {
                        $('#cdhsvrcc', '#frmCab').val('');
                    }
                    if ( msie > 0) { //valida se o navegador eh IE
                        $('#cdhsvrcc', '#frmCab').focus();
                    } else if (e.keyCode == 13) { //botao ENTER pois o TAB ja da foco no campo seguinte
                        $('#cdhsvrcc', '#frmCab').focus();
                    }
                }
                return false;
            }
        });

        $('#cdhsvrcc', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {

                var retorno = validaCodigoHistorico($(this));

                if (retorno != '') {
                    showError("error", retorno, "Alerta - Ayllos", "$('#" + $(this).attr('id') + "', '#frmCab').focus();hideMsgAguardo();");
                } else {
                    hideMsgAguardo();                    
                    if ($('#cdhsraap', '#frmCab').val() == 0) {
                        $('#cdhsraap', '#frmCab').val('');
                    }
                    if ( msie > 0) { //valida se o navegador eh IE
                        $('#cdhsraap', '#frmCab').focus();
                    } else if (e.keyCode == 13) { //botao ENTER pois o TAB ja da foco no campo seguinte
                        $('#cdhsraap', '#frmCab').focus();
                    }
                }
                return false;
            }
        });

        $('#cdhsraap', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                var retorno = validaCodigoHistorico($(this));

                if (retorno != '') {
                    showError("error", retorno, "Alerta - Ayllos", "$('#" + $(this).attr('id') + "', '#frmCab').focus();hideMsgAguardo();");
                } else {
                    hideMsgAguardo();
                    if ($('#cdhsnrap', '#frmCab').val() == 0) {
                        $('#cdhsnrap', '#frmCab').val('');
                    }
                    if ( msie > 0) { //valida se o navegador eh IE
                        $('#cdhsnrap', '#frmCab').focus();
                    } else if (e.keyCode == 13) { //botao ENTER pois o TAB ja da foco no campo seguinte
                        $('#cdhsnrap', '#frmCab').focus();
                    }
                }
                return false;
            }
        });

        $('#cdhsnrap', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                var retorno = validaCodigoHistorico($(this));

                if (retorno != '') {
                    showError("error", retorno, "Alerta - Ayllos", "$('#" + $(this).attr('id') + "', '#frmCab').focus();hideMsgAguardo();");
                } else {
                    hideMsgAguardo();
                    if ($('#cdhsprap', '#frmCab').val() == 0) {
                        $('#cdhsprap', '#frmCab').val('');
                    }
                    if ( msie > 0) { //valida se o navegador eh IE
                        $('#cdhsprap', '#frmCab').focus();
                    } else if (e.keyCode == 13) { //botao ENTER pois o TAB ja da foco no campo seguinte
                        $('#cdhsprap', '#frmCab').focus();
                    }
                }
                return false;
            }
        });

        $('#cdhsprap', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                var retorno = validaCodigoHistorico($(this));

                if (retorno != '') {
                    showError("error", retorno, "Alerta - Ayllos", "$('#" + $(this).attr('id') + "', '#frmCab').focus();hideMsgAguardo();");
                } else {
                    hideMsgAguardo();
                    if ($('#cdhsrvap', '#frmCab').val() == 0) {
                        $('#cdhsrvap', '#frmCab').val('');
                    }
                    if ( msie > 0) { //valida se o navegador eh IE
                        $('#cdhsrvap', '#frmCab').focus();
                    } else if (e.keyCode == 13) { //botao ENTER pois o TAB ja da foco no campo seguinte
                        $('#cdhsrvap', '#frmCab').focus();
                    }
                }
                return false;
            }
        });

        $('#cdhsrvap', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                var retorno = validaCodigoHistorico($(this));

                if (retorno != '') {
                    showError("error", retorno, "Alerta - Ayllos", "$('#" + $(this).attr('id') + "', '#frmCab').focus();hideMsgAguardo();");
                } else {
                    hideMsgAguardo();
                    if ($('#cdhsrdap', '#frmCab').val() == 0) {
                        $('#cdhsrdap', '#frmCab').val('');
                    }
                    if ( msie > 0) { //valida se o navegador eh IE
                        $('#cdhsrdap', '#frmCab').focus();
                    } else if (e.keyCode == 13) { //botao ENTER pois o TAB ja da foco no campo seguinte
                        $('#cdhsrdap', '#frmCab').focus();
                    }
                }
                return false;
            }
        });

        $('#cdhsrdap', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                var retorno = validaCodigoHistorico($(this));

                if (retorno != '') {
                    showError("error", retorno, "Alerta - Ayllos", "$('#" + $(this).attr('id') + "', '#frmCab').focus();hideMsgAguardo();");
                } else {
                    hideMsgAguardo();
                    if ($('#cdhsirap', '#frmCab').val() == 0) {
                        $('#cdhsirap', '#frmCab').val('');
                    }
                    if ( msie > 0) { //valida se o navegador eh IE
                        $('#cdhsirap', '#frmCab').focus();
                    } else if (e.keyCode == 13) { //botao ENTER pois o TAB ja da foco no campo seguinte
                        $('#cdhsirap', '#frmCab').focus();
                    }
                }
                return false;
            }
        });

        $('#cdhsirap', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                var retorno = validaCodigoHistorico($(this));

                if (retorno != '') {
                    showError("error", retorno, "Alerta - Ayllos", "$('#" + $(this).attr('id') + "', '#frmCab').focus();hideMsgAguardo();");
                } else {
                    hideMsgAguardo();
                    if ($('#cdhsrgap', '#frmCab').val() == 0) {
                        $('#cdhsrgap', '#frmCab').val('');
                    }
                    if ( msie > 0) { //valida se o navegador eh IE
                        $('#cdhsrgap', '#frmCab').focus();
                    } else if (e.keyCode == 13) { //botao ENTER pois o TAB ja da foco no campo seguinte
                        $('#cdhsrgap', '#frmCab').focus();
                    }
                }
                return false;
            }
        });

        $('#cdhsrgap', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                var retorno = validaCodigoHistorico($(this));

                if (retorno != '') {
                    showError("error", retorno, "Alerta - Ayllos", "$('#" + $(this).attr('id') + "', '#frmCab').focus();hideMsgAguardo();");
                } else {
                    hideMsgAguardo();
                    if ($('#cdhsvtap', '#frmCab').val() == 0) {
                        $('#cdhsvtap', '#frmCab').val('');
                    }
                    if ( msie > 0) { //valida se o navegador eh IE
                        $('#cdhsvtap', '#frmCab').focus();
                    } else if (e.keyCode == 13) { //botao ENTER pois o TAB ja da foco no campo seguinte
                        $('#cdhsvtap', '#frmCab').focus();
                    }
                }
                return false;
            }
        });

        $('#cdhsvtap', '#frmCab').unbind('keydown').bind('keydown', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                var retorno = validaCodigoHistorico($(this));

                if (retorno != '') {
                    showError("error", retorno, "Alerta - Ayllos", "$('#" + $(this).attr('id') + "', '#frmCab').focus();hideMsgAguardo();");
                } else {
                    hideMsgAguardo();                
                    if ( msie > 0) { //valida se o navegador eh IE
                        $('#btProseg', '#frmCab').focus();
                    } else if (e.keyCode == 13) { //botao ENTER pois o TAB ja da foco no campo seguinte
                        $('#btProseg', '#frmCab').focus();
                    }
                }
                return false;
            }
        });

    });


    /*
     * @opcao D - Historicos dos Produtos
     * @name validaCodigoHistorico
     * @params obj DOM HTML
     * @returns Mensagem de erro para historicos invalidos
     */
    function validaCodigoHistorico(obj)
    {
        var campo = $(obj).attr('id');
        var codigo = $.trim($(obj).val());
        var retorno = 0;

        if (codigo > 0) {

            showMsgAguardo("Aguarde, validando dados...");

            var tipoHistorico = '';
            if (campo == 'cdhsvrcc' || campo == 'cdhsraap' || campo == 'cdhsnrap' || campo == 'cdhsprap' || campo == 'cdhsrdap') {
                tipoHistorico = 'crédito';
            } else {
                tipoHistorico = 'dédito';
            }

            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_historico.php",
                dataType: "json",
                async: false,
                data: {
                    flgopcao: 'VCH',
                    campo: campo,
                    valor: codigo
                },
                success: function(data) {
                    $.each(data.records, function(i, item) {

                        if (item.valido == 'N') {
                            retorno = 'Histórico não cadastrado';
                        } else {
                            if (item.indebcre == 'N') {
                                retorno = 'Histórico inválido para ' + tipoHistorico;
                            } else {
                                if (item.estrutura == 'N') {
                                    retorno = 'Não é uma estrutura válida para este lançamento';
                                } else {
                                    retorno = '';
                                }
                            }
                        }
                    });
                }
            });

            if (retorno != '') {
                $(obj).val('');
            }

        } else {
            var labelCampo = $(obj).parent().find('label').text().replace(':', '');
            retorno = 'Informe o campo: ' + labelCampo;
            $(obj).val('');
        }
        return retorno;
    }


    function carregaDadosProduto(obj)
    {
        if ($(obj).val() > 0) {
            if ($("#hdnProdSel").val() != $(obj).val()) {
                possuiCarteira();

                if ($('#cdhscacc', '#frmCab').val() == 0) {
                    $('#cdhscacc', '#frmCab').val('');
                }

                $('#cdhscacc', '#frmCab').focus();
            }
        }
        $("#hdnProdSel").val($(obj).val());
    }


    /**
     * @opcao D - Historicos dos Produtos
     * @name consultaIndexadorProduto
     * @returns retorna o indexador
     */
    function consultaHistoricoProduto()
    {

        if ($('#cdprodut').val() > 0) {
            $('#cdprodut').attr('disabled', true);
            showMsgAguardo("Aguarde, carregando dados...");

            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_historico.php",
                dataType: "json",
                async: false,
                data: {
                    flgopcao: 'C',
                    cdprodut: $('#cdprodut').val()
                },
                success: function(data) {
                    if (data.rows > 0) {
                        $.each(data.records, function(i, item) {
                            cCdhscacc.val(item.cdhscacc);
                            cCdhsvrcc.val(item.cdhsvrcc);
                            cCdhsraap.val(item.cdhsraap);
                            cCdhsnrap.val(item.cdhsnrap);
                            cCdhsprap.val(item.cdhsprap);
                            cCdhsrvap.val(item.cdhsrvap);
                            cCdhsrdap.val(item.cdhsrdap);
                            cCdhsirap.val(item.cdhsirap);
                            cCdhsrgap.val(item.cdhsrgap);
                            cCdhsvtap.val(item.cdhsvtap);
                        });

                    }
                }
            });
            ocultaMsgAguardo();
        } else {
            showError("error", "Selecione o produto.", "Alerta - Ayllos", "");
        }

    }


    function possuiCarteira()
    {

        if ($("#hdnAcao").val() == 'A') {
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_historico.php",
                dataType: "json",
                async: false,
                data: {
                    flgopcao: 'V',
                    cdprodut: $('#cdprodut').val()
                },
                success: function(data) {
                    if (data.rows > 0) {
                        $.each(data.records, function(i, item) {
                            var retorno = item.carteira;
                            if (retorno == 'S') {
                                showError("error", 'Operação inválida produto possui carteira cadastrada', "Alerta - Ayllos", "$('#cdprodut', '#frmCab').focus();");
                            } else if (retorno == 'N') {
                                showMsgAguardo("Aguarde, validando produto...");
                                cCdhscacc.attr("disabled", false);
                                cCdhsvrcc.attr("disabled", false);
                                cCdhsraap.attr("disabled", false);
                                cCdhsnrap.attr("disabled", false);
                                cCdhsprap.attr("disabled", false);
                                cCdhsrvap.attr("disabled", false);
                                cCdhsrdap.attr("disabled", false);
                                cCdhsirap.attr("disabled", false);
                                cCdhsrgap.attr("disabled", false);
                                cCdhsvtap.attr("disabled", false);
                                $('#historicosDados .linhaBotoes').show();
                                btnProseg1.show();
                                $("tr.linhaBotoes #btVoltar").css('margin-left', '170px');
                                consultaHistoricoProduto();
                                ocultaMsgAguardo();
                            }

                        });
                    }
                }
            });
        } else {
            consultaHistoricoProduto();
        }
    }


    function validaCadastro()
    {
        var retorno = '';
        
        showMsgAguardo('Aguarde, validando dados...')

        if ($.trim($("#cdhscacc").val()) == '' || $("#cdhscacc").val() == 0) {
            showError("error", "Preencha Débito Aplicação.", "Alerta - Ayllos", "$('#cdhscacc', '#frmCab').val('').focus();hideMsgAguardo();");
            return false;
        } else { //valida codigo informado
            retorno = validaCodigoHistorico("#cdhscacc");
            if (retorno != '') {
                showError("error", retorno, "Alerta - Ayllos", "$('#cdhscacc', '#frmCab').val('').focus();hideMsgAguardo();");

            } else { //valida o proximo campo
                if ($.trim($("#cdhsvrcc").val()) == '' || $("#cdhsvrcc").val() == 0) {
                    showError("error", "Preencha Crédito Resgate/Vencimento Aplicação.", "Alerta - Ayllos", "$('#cdhsvrcc', '#frmCab').val('').focus();hideMsgAguardo();");
                    return false;
                } else { //valida codigo informado
                    retorno = validaCodigoHistorico($("#cdhsvrcc"));
                    if (retorno != '') {
                        showError("error", retorno, "Alerta - Ayllos", "$('#cdhsvrcc', '#frmCab').val('').focus();hideMsgAguardo();");

                    } else { //valida o proximo campo
                        if ($.trim($("#cdhsraap").val()) == '' || $("#cdhsraap").val() == 0) {
                            showError("error", "Preencha Crédito Renovação Aplicação.", "Alerta - Ayllos", "$('#cdhsraap', '#frmCab').val('').focus();hideMsgAguardo();");
                            return false;
                        } else {//valida o codigo informado
                            retorno = validaCodigoHistorico($("#cdhsraap"));
                            if (retorno != '') {
                                showError("error", retorno, "Alerta - Ayllos", "$('#cdhsraap', '#frmCab').val('').focus();hideMsgAguardo();");

                            } else { //valida o proximo campo
                                if ($.trim($("#cdhsnrap").val()) == '' || $("#cdhsnrap").val() == 0) {
                                    showError("error", "Preencha Crédito Aplicação Recurso Novo.", "Alerta - Ayllos", "$('#cdhsnrap', '#frmCab').val('').focus();hideMsgAguardo();");
                                    return false;
                                } else { //valida o codigo informado
                                    retorno = validaCodigoHistorico($("#cdhsnrap"));
                                    if (retorno != '') {
                                        showError("error", retorno, "Alerta - Ayllos", "$('#cdhsnrap', '#frmCab').val('').focus();hideMsgAguardo();");

                                    } else { //valida o proximo campo
                                        if ($.trim($("#cdhsprap").val()) == '' || $("#cdhsprap").val() == 0) {
                                            showError("error", "Preencha Crédito Atualização Juros.", "Alerta - Ayllos", "$('#cdhsprap', '#frmCab').val('').focus();hideMsgAguardo();");
                                            return false;
                                        } else {
                                            retorno = validaCodigoHistorico($("#cdhsprap"));
                                            if (retorno != '') {
                                                showError("error", retorno, "Alerta - Ayllos", "$('#cdhsprap', '#frmCab').val('').focus();hideMsgAguardo();");

                                            } else { //valida o proximo campo
                                                if ($.trim($("#cdhsrvap").val()) == '' || $("#cdhsrvap").val() == 0) {
                                                    showError("error", "Preencha Débito Reversão Atualização Juros.", "Alerta - Ayllos", "$('#cdhsrvap', '#frmCab').focus();hideMsgAguardo();");
                                                    return false;
                                                } else {
                                                    retorno = validaCodigoHistorico($("#cdhsrvap"));
                                                    if (retorno != '') {
                                                        showError("error", retorno, "Alerta - Ayllos", "$('#cdhsrvap', '#frmCab').val('').focus();hideMsgAguardo();");

                                                    } else { //valida o proximo campo
                                                        if ($.trim($("#cdhsrdap").val()) == '' || $("#cdhsrdap").val() == 0) {
                                                            showError("error", "Preencha Crédito Rendimento.", "Alerta - Ayllos", "$('#cdhsrdap', '#frmCab').focus();hideMsgAguardo();");
                                                            return false;
                                                        } else {
                                                            retorno = validaCodigoHistorico($("#cdhsrdap"));
                                                            if (retorno != '') {
                                                                showError("error", retorno, "Alerta - Ayllos", "$('#cdhsrdap', '#frmCab').val('').focus();hideMsgAguardo();");

                                                            } else { //valida o proximo campo
                                                                if ($.trim($("#cdhsirap").val()) == '' || $("#cdhsirap").val() == 0) {
                                                                    showError("error", "Preencha Débito IRRF.", "Alerta - Ayllos", "$('#cdhsirap', '#frmCab').val('').focus();hideMsgAguardo();");
                                                                    return false;
                                                                } else {
                                                                    retorno = validaCodigoHistorico($("#cdhsirap"));
                                                                    if (retorno != '') {
                                                                        showError("error", retorno, "Alerta - Ayllos", "$('#cdhsirap', '#frmCab').val('').focus();hideMsgAguardo();");

                                                                    } else { //valida o proximo campo
                                                                        if ($.trim($("#cdhsrgap").val()) == '' || $("#cdhsrgap").val() == 0) {
                                                                            showError("error", "Débito Resgate.", "Alerta - Ayllos", "$('#cdhsrgap', '#frmCab').val('').focus();hideMsgAguardo();");
                                                                            return false;
                                                                        } else {
                                                                            retorno = validaCodigoHistorico($("#cdhsrgap"));
                                                                            if (retorno != '') {
                                                                                showError("error", retorno, "Alerta - Ayllos", "$('#cdhsrgap', '#frmCab').val('').focus();hideMsgAguardo();");

                                                                            } else { //valida o proximo campo
                                                                                if ($.trim($("#cdhsvtap").val()) == '' || $("#cdhsvtap").val() == 0) {
                                                                                    showError("error", "Débito Vencimento.", "Alerta - Ayllos", "$('#cdhsvtap', '#frmCab').val('').focus();hideMsgAguardo();");
                                                                                    return false;
                                                                                } else {
                                                                                    retorno = validaCodigoHistorico($("#cdhsvtap"));
                                                                                    if (retorno != '') {
                                                                                        showError("error", retorno, "Alerta - Ayllos", "$('#cdhsvtap', '#frmCab').val('').focus();hideMsgAguardo();");

                                                                                    } else { //validacao final
                                                                                        //solicita a confirmacao do cadastro
                                                                                        showConfirmacao('Confirma a alteração nos históricos do produto ' + $("#cdprodut option:selected").text() + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gravaHistorico();', 'hideMsgAguardo();', 'sim.gif', 'nao.gif');
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * @opcao H - Historicos dos Produtos
     * @name gravaHistorico
     * @returns 
     */
    function gravaHistorico()
    {
        showMsgAguardo("Aguarde, carregando dados...");
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_historico.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'A',
                cdprodut: $('#cdprodut option:selected').val(),
                cdhscacc: $('#cdhscacc').val(),
                cdhsvrcc: $('#cdhsvrcc').val(),
                cdhsraap: $('#cdhsraap').val(),
                cdhsnrap: $('#cdhsnrap').val(),
                cdhsprap: $('#cdhsprap').val(),
                cdhsrvap: $('#cdhsrvap').val(),
                cdhsrdap: $('#cdhsrdap').val(),
                cdhsirap: $('#cdhsirap').val(),
                cdhsrgap: $('#cdhsrgap').val(),
                cdhsvtap: $('#cdhsvtap').val()
            },
            success: function(data) {
                if (data.erro == 'N') {
                    resetaForm('historicosDados');
                    ocultaMsgAguardo();
                } else {
                    showError("error", data.msg, "Alerta - Ayllos", "hideMsgAguardo();");
                }
            }
        });
        ocultaMsgAguardo();
    }

    function carregaComboProdutos(acao)
    {
        var htmlOpcoes = '<option value="0">-- Selecione --</option>';

        showMsgAguardo("Aguarde, carregando dados...");

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_historico.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'CAR',
                stracao: acao
            },
            success: function(data) {
                if (data.rows > 0) {
                    $.each(data.records, function(i, item) {
                        htmlOpcoes += '<option value="' + i + '">' + item + '</option>';
                    });

                }
            }
        });

        $("#historicosDados #cdprodut").empty().append(htmlOpcoes);
        ocultaMsgAguardo();

    }

</script>
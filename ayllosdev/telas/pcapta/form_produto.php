<?php
/* FONTE        : form_produto.php
 * CRIA��O      : Jean Michel         
 * DATA CRIA��O : 30/04/2014
 * OBJETIVO     : Formulario de produto da tela PCAPTA
 * --------------
 * ALTERA��ES   : Alterei a forma de montagem do combo de produtos
 *                para o mesmo carregar em tempo real as altera��es
 *                [Carlos Rafael Tanholi - 29/07/2014]
 */

session_start();

require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

setVarSession('nmrotina', 'PRODUTOS');

// Montar o xml de Requisicao Indexadores
$xmlIndice .= "<Root>";
$xmlIndice .= " <Dados>";
$xmlIndice .= "   <cddindex>0</cddindex>";
$xmlIndice .= " </Dados>";
$xmlIndice .= "</Root>";

$xmlResultIndice = mensageria($xmlIndice, "PCAPTA", "INDPCA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
$xmlObjIndice = getObjectXML($xmlResultIndice);

//-----------------------------------------------------------------------------------------------
// Controle de Erros
//-----------------------------------------------------------------------------------------------
if (strtoupper($xmlObjIndice->roottag->tags[0]->name == 'ERRO')) {
    $msgErro = $xmlObj->roottag->tags[0]->cdata;
    if ($msgErro == null || $msgErro == '') {
        $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
    }
    echo "<script>";
    exibirErro('error', $msgErro, 'Alerta - Ayllos', '', false);
    echo "</script>";
} else {
    $registrosIndice = $xmlObjIndice->roottag->tags;
}
?>
<div id="dadosProdutos">
    <fieldset>
        <legend>Dados do Produto</legend>
        <table>
            <tr>
                <td>
                    <label for="nmprodut" >Nome:</label>
                    <input type="text" name="nmprodut" id="nmprodut" value="" maxlength="20"/>
                </td>
            </tr>
            <tr>
                <td>                    
                    <label style="display:none;" for="nmprodus" >Nome:</label>
                    <select name="nmprodus" id="nmprodus" style="display:none;"></select>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="idsitpro">Situa&ccedil;&atilde;o:</label>
                    <select name="idsitpro" id="idsitpro">
                        <option value="0" >-- Selecione --</option>                        
                        <option value="1" >Ativo</option>
                        <option value="2" >Inativo</option>
                    </select>
                </td>
            </tr>         
            <tr>
                <td>
                    <label for="cddindex">Indexador:</label>
                    <select name="cddindex" id="cddindex">
                        <option value="0">-- Selecione --</option>
                        <?php
                        foreach ($registrosIndice as $registroIndice) {
                            echo '<option value="' . str_replace(PHP_EOL, "", $registroIndice->tags[0]->cdata) . '">' . $registroIndice->tags[1]->cdata . '</option>';
                        }
                        ?>
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="idtippro">Tipo:</label>
                    <select name="idtippro" id="idtippro">
                        <option value="0">-- Selecione --</option>                        
                        <option value="1">PR&Eacute;-FIXADA</option>
                        <option value="2">P&Oacute;S-FIXADA</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="idtxfixa">Taxa Fixa:</label>
                    <input type="radio" name="idtxfixa" id="idtxfixa" value="1" ><label>&nbsp;&nbsp;&nbsp;Sim</label>
                    <input type="radio" name="idtxfixa" id="idtxfixa" value="2" style="margin-left: 20px;" ><label>&nbsp;&nbsp;&nbsp;N&atilde;o</label>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="idacumul">Cumulativa:</label>
                    <input type="radio" name="idacumul" id="idacumul" value="1" ><label>&nbsp;&nbsp;&nbsp;Sim</label>
                    <input type="radio" name="idacumul" id="idacumul" value="2" style="margin-left: 20px;" ><label>&nbsp;&nbsp;&nbsp;N&atilde;o</label>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="indplano">Apl. Programada:</label>
                    <input type="radio" name="indplano" id="indplano" value="1" ><label>&nbsp;&nbsp;&nbsp;Sim</label>
                    <input type="radio" name="indplano" id="indplano" value="2" style="margin-left: 20px;" ><label>&nbsp;&nbsp;&nbsp;N&atilde;o</label>
                </td>
            </tr>
            <tr class="linhaBotoes">
                <td>
                    <a href="javascript:void(0);" class="botao" class="btnVoltar" id="btVoltar" name="btVoltar" onclick="resetaForm('dadosProdutos');" >Voltar</a>
                    <a href="javascript:void(0);" class="botao" id="btProseg" nome="btProseg" onclick="executaOpcao();">Prosseguir</a>
                    
                    <input type="hidden" name="hdncdprodut" id="hdncdprodut" value="0" />
                    <input type="hidden" name="hdnAcaoP" id="hdnAcaoP" value="" />
                    <input type="hidden" name="hdnCarteira" id="hdnCarteira" value="" />
                    <input type="hidden" name="hdnModalidade" id="hdnModalidade" value="" />
                    <input type="hidden" id="hdnProdSel" value="0" />                    
                </td>
            </tr>
        </table>
    </fieldset>
    <table class="tableAcoes">
        <tr>
            <td>
                <a href="javascript:void(0);" class="botao" id="btVoltar"  onclick="escolheOpcao('P', 'V');">Voltar</a>
                <a href="javascript:void(0);" class="botao" id="btAltera"  onClick="escolheOpcao('P', 'A');">Alterar</a>
                <a href="javascript:void(0);" class="botao" id="btConsul"  onclick="escolheOpcao('P', 'C');">Consultar</a>
                <a href="javascript:void(0);" class="botao" id="btExclui"  onclick="escolheOpcao('P', 'E');">Excluir</a>
                <a href="javascript:void(0);" class="botao" id="btInclui"  onclick="escolheOpcao('P', 'I');">Inserir</a>
            </td>
        </tr>
    </table>
</div>
<style type="text/css">
    table.tableAcoes {
        margin-left: 120px;        
    }
    
    #nmprodus {
        height: 20px !important;
    }
    
    #dadosProdutos fieldset table {
        margin-left: 75px;
    }
    #hdncdprodut {
        display: none;
    }

    tr.linhaBotoes {
        display: none;
    }
    tr.linhaBotoes #btVoltar {
        margin-left: 125px;
    } 
</style>
<script type="text/javascript">
    $(function() {
        
        $('#nmprodus', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                carregaDadosProdutos();
                return false;
            }
        });
        $('#nmprodus', '#frmCab').unbind('click').bind('click', function(e) {
            carregaDadosProdutos();
            return false;            
            
        });
        
        $('#nmprodut', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#idsitpro', '#frmCab').focus();
                return false;
            }
        });        
        $('#idsitpro', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                
                if ( $("#hdnCarteira").val() == 'S' || $("#hdnModalidade").val() == 'S' ) {
                    $('#idacumul', '#frmCab').focus();   
                } else {
                    $('#cddindex', '#frmCab').focus();
                }
                
                return false;
            }
        });        
        $('#cddindex', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#idtippro', '#frmCab').focus();
                return false;
            }
        });        
        $('#idtippro', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#idtxfixa', '#frmCab').focus();
                return false;
            }
        });        
        $('#idtxfixa', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#idacumul', '#frmCab').focus();
                return false;
            }
        });        
        $('#idacumul', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#indplano', '#frmCab').focus();
                return false;
            }
        });
        $('#indplano', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#btProseg', '#frmCab').focus();
                return false;
            }
        });
        
    });


    /**
     * @opcao P - Produtos de Captacao
     * @name carregaDadosProdutos
     * @returns carrega a tela com dados do produto
     */
    function carregaDadosProdutos()
    {
        if (cNmprodus.val() > 0) {
            
            if ($("#hdnProdSel").val() != cNmprodus.val()) {
                         
                showMsgAguardo("Aguarde, carregando dados...");

                $.ajax({
                    type: "POST",
                    url: UrlSite + "telas/pcapta/ajax_produto.php",
                    dataType: "json",
                    async: false,
                    data: {
                        flgopcao: 'C',
                        cdprodut: cNmprodus.val()
                    },
                    success: function(data) {
                        if (data.rows == 1) {
                            ocultaMsgAguardo();

                            $.each(data.records, function(i, item) {

                                //carrega situacao do produto
                                $("#idsitpro option").each(function(i, obj) {
                                    if ($(obj).val() == item.idsitpro) {
                                        $(obj).attr('selected', 'selected');
                                    }
                                });

                                //seleciona o indexador do produto
                                $("#cddindex option").each(function(i, obj) {
                                    if ($(obj).val() == item.cddindex) {
                                        $(obj).attr('selected', 'selected');
                                    }
                                });

                                //seleciona o tipo do produto
                                $("#idtippro option").each(function(i, obj) {
                                    if ($(obj).val() == item.idtippro) {
                                        $(obj).attr('selected', 'selected');
                                    }
                                });

                                $("#dadosProdutos table input[type=radio]").each(function(i, obj) {
                                    switch ($(obj).attr('id')) {
                                                case 'idtxfixa': // taxa fixa
                                                    if ($(obj).val() == item.idtxfixa) {
                                                        $(obj).attr('checked', 'checked');
                                                    }
                                                    break;
                                                case 'idacumul': // acumula
                                                    if ($(obj).val() == item.idacumul) {
                                                        $(obj).attr('checked', 'checked');
                                                    }
                                                    break;
                                                case 'indplano': //programada?
                                                    if ($(obj).val() == item.indplano) {
                                                        $(obj).attr('checked', 'checked');
                                                    }
                                                    break;
                                    }
                                });
                            });

                            if ($("#hdnAcaoP", "#" + frmCab).val() == 'C') {
                                btnProseg1.hide();
                                $("#btVoltar").css('margin-left', '180px');
                                cNmprodus.attr('disabled', true);                        
                            }

                            if ($("#hdnAcaoP", "#" + frmCab).val() == 'E') {
                                cNmprodus.attr('disabled', true);
                                $("#hdnAcaoP", "#" + frmCab).val('EX');
                            }

                            if ($("#hdnAcaoP", "#" + frmCab).val() == 'A') {
                                //esconde o campo select de nome
                                rNmprodus.hide();
                                //desabilita e esconde
                                cNmprodus.attr('disabled', true).hide();
                                //mostra  o campo texto de nome
                                rNmprodut.show();
                                //habilita, mostra o campo e atribui o nome do produto filtrado ao value
                                cNmprodut.attr('disabled', false).show().val(cNmprodus.find("option:selected").text());
                                //atribui o ID do produto selecionado ao hidden
                                $("#hdncdprodut").val(cNmprodus.find("option:selected").val());
                                //habilita os campos de acordo com a regra de carteira do produto
                                habilitaAlteracaoProduto();
                                //atribui acao de alteracao
                                $("#hdnAcaoP", "#" + frmCab).val('AL');
                            }
                        } else {
                            ocultaMsgAguardo();
                            if (data.erro == 'S') {
                                alert(data.msg)
                            }
                            eval(data);
                        }
                    },
                    error: function(data) {
                        eval(data)
                    }
                });
                ocultaMsgAguardo();

                if ($("#hdnAcaoP").val() == 'C') {
                    $('#btVoltar').focus();
                } else if ($("#hdnAcaoP").val() == 'EX') {
                    $('#btProseg').focus();
                } else {
                    $('#idsitpro').focus();
                }            
            }
        }
        $("#hdnProdSel").val(cNmprodus.val());
    }

    /**
     * @opcao P - Produtos de Captacao
     * @name carregaComboProdutos
     * @returns carrega o combo com os produtos
     */
    function carregaComboProdutos()
    {
        var htmlOpcoes = '<option value="0">-- Selecione --</option>';
        showMsgAguardo("Aguarde, carregando dados...");

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_produto.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'C',
                cdprodut: 0
            },
            success: function(data) {
                if (data.rows > 0) {
                    $.each(data.records, function(i, item) {
                        htmlOpcoes += '<option value="' + item.cdprodut + '">' + item.nmprodut + '</option>';
                    });
                    $("#nmprodus").empty().append(htmlOpcoes);
                } else {
                    eval(data);
                }
            }
        });
        ocultaMsgAguardo();
    }



    /**
     * @opcao P - Produtos de Captacao
     * @name executaOpcap
     * @returns Executa funcoes diversas de acordo com a operacao
     */
    function executaOpcao()
    {

        switch ($("#hdnAcaoP", "#" + frmCab).val()) {

            case 'A':
                carregaDadosProdutos();
                break;

            case 'AL':
                validaAlteracaoProduto();
                break;

            case 'C':
                carregaDadosProdutos();
                break;

            case 'E':
                carregaDadosProdutos();
                break;

            case 'EX':
                validaExclusaoProduto();
                break;

            case 'I':
                $("#hdncdprodut").val('');
                validaDadosProduto();
                break;

        }

    }


    /**
     * @opcao P - Produtos de Captacao
     * @name habilitaAlteracaoProduto
     * @returns Habilita os campos para edicao do produto
     */
    function habilitaAlteracaoProduto() {

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_produto.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'V',
                cdprodut: $("#nmprodus option:selected").val(),
                nmprodut: cNmprodut.val(),
                idsitpro: cIdsitpro.val(),
                cddindex: cCddindex.val(),
                idtippro: cIdtippro.val(),
                idtxfixa: cIdtxfixa.val(),
                idacumul: cIdacumul.val(),
                indplano: cIndplano.val()
            },
            success: function(retorno) {
                if (retorno.rows == 1) {
                    showMsgAguardo("Aguarde, carregando dados...");
                    $.each(retorno.records, function(i, item) {
                        $("#hdnCarteira").val(item.carteira);
                        $("#hdnModalidade").val(item.modalidade);                        
                        //caso nao encontre nenhuma carteira e modalidade
                        if (item.carteira == 'N' && item.modalidade == 'N') {
                            cNmprodut.attr("disabled", false);
                            cIdsitpro.attr("disabled", false);
                            cCddindex.attr("disabled", false);
                            cIdtippro.attr("disabled", false);
                            cIdtxfixa.attr("disabled", false);
                            cIdacumul.attr("disabled", false);
                            cIndplano.attr("disabled", false);
                        } else { //produto possui carteira ou modalidade cadastrada
                            //cNmprodut.attr("disabled", false); //nome
                            cIdsitpro.attr("disabled", false); //situacao
                            cIdacumul.attr("disabled", false); //cumulatividade
                            cIndplano.attr("disabled", false); //APl. Programada
                        }
                    });
                    ocultaMsgAguardo();
                } else if (retorno.erro == 'S') {
                    showError("error", retorno.msg, "Alerta - Ayllos", "");
                }
            }
        });
    }


    /**
     * @opcao P - Produtos de Captacao
     * @name validaDadosProduto
     * @returns valida os dados do produto
     */
    function validaDadosProduto() {

        var vr_idtxfixa = 0;
        var vr_idacumul = 0;
        var vr_indplano = 0; 

        $('input[id="idtxfixa"]').each(function() {
            if ($(this).is(':checked')) {
                vr_idtxfixa = $(this).val();
            }
        });
        $('input[id="idacumul"]').each(function() {
            if ($(this).is(':checked')) {
                vr_idacumul = $(this).val();
            }
        });   
        $('input[id="indplano"]').each(function() {
            if ($(this).is(':checked')) {
                vr_indplano = $(this).val();
            }
        });   
                
        showMsgAguardo("Aguarde, validando dados...");
        
        if (validaCamposTela()) {
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_produto.php",
                dataType: "json",
                async: false,
                data: {
                    flgopcao: 'V',
                    cdprodut: $("#nmprodus option:selected").val(),
                    nmprodut: cNmprodut.val(),
                    idsitpro: cIdsitpro.val(),
                    cddindex: cCddindex.val(),
                    idtippro: cIdtippro.val(),
                    idtxfixa: vr_idtxfixa,
                    idacumul: vr_idacumul,
                    indplano: vr_indplano
                },
                success: function(retorno) {
                    if (retorno.rows == 1) {
                        $.each(retorno.records, function(i, item) {
                            if (item.nome == 'N' && item.parametro == 'N') {
                                showConfirmacao('Confirma a inclus&atilde;o do produto ' + cNmprodut.val() + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gravaDadosProduto();ocultaMsgAguardo();', 'ocultaMsgAguardo();', 'sim.gif', 'nao.gif');
                            } else {
                                if (item.nome == 'S') {
                                    showError("error", "O nome do produto informado j&aacute; est&aacute; cadastrado.", "Alerta - Ayllos", "$('#nmprodut', '#frmCab').focus();ocultaMsgAguardo();");
                                } else if (item.parametro == 'S') {
                                    showConfirmacao("J&aacute; existe produto cadastrado com os par&acirc;metros informados. Confirma a inser&ccedil;&atilde;o do produto " + cNmprodut.val() + "?", 'Confirma&ccedil;&atilde;o - Ayllos', 'gravaDadosProduto();ocultaMsgAguardo();', 'ocultaMsgAguardo();', 'sim.gif', 'nao.gif');
                                }
                            }
                        });
                    } else if (retorno.erro == 'S') {
                        showError("error", retorno.msg, "Alerta - Ayllos", "ocultaMsgAguardo();");
                    }
                }
            });
        }
    }

    /**
     * @opcao P - Produtos de Captacao
     * @name validaExclusaoProduto
     * @returns valida a exclusao do produto
     */
    function validaExclusaoProduto() {
        
        var vr_idtxfixa = 0;
        var vr_idacumul = 0;
        var vr_indplano = 0;

        $('input[id="idtxfixa"]').each(function() {
            if ($(this).is(':checked')) {
                vr_idtxfixa = $(this).val();
            }
        });
        $('input[id="idacumul"]').each(function() {
            if ($(this).is(':checked')) {
                vr_idacumul = $(this).val();
            }
        });        
            $('input[id="indplano"]').each(function() {
            if ($(this).is(':checked')) {
                vr_indplano = $(this).val();
            }
        });   
    
        showMsgAguardo("Aguarde, processando dados...");
        
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_produto.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'V',
                cdprodut: $("#nmprodus option:selected").val(),
                nmprodut: cNmprodut.val(),
                idsitpro: cIdsitpro.val(),
                cddindex: cCddindex.val(),
                idtippro: cIdtippro.val(),
                idtxfixa: vr_idtxfixa,
                idacumul: vr_idacumul,
                indplano: vr_indplano
            },
            success: function(retorno) {
                if (retorno.rows == 1) {
                    var msg = '';
                    $.each(retorno.records, function(i, item) {
                        // se o produto nao tiver carteira
                        if (item.carteira == 'N') {
                            showConfirmacao('Confirma a exclus&atilde;o do produto ' + cNmprodus.find("option:selected").text() + ' ?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluiDadosProduto();', 'hideMsgAguardo();', 'sim.gif', 'nao.gif');
                        } else {
                            btnProseg1.hide();
                            btnCancel1.css('margin-left', '180px');
                            btnCancel1.text('Voltar');
                            
                            if (item.carteira == "S") {
                                msg = 'O produto possui carteira cadastrada.'; 
                            } else if (item.modalidade == "S") {
                                msg = 'O produto possui modalidade cadastrada.';
                            }
                            showError("error", 'Exclus&atilde;o n&atilde;o permitida. ' + msg, "Alerta - Ayllos", "hideMsgAguardo();");
                        }
                    });
                } else if (retorno.erro == 'S') {
                    showError("error", retorno.msg, "Alerta - Ayllos", "ocultaMsgAguardo();");
                }
            }
        });

    }

    /**
     * @opcao P - Produtos de Captacao
     * @name validaAlteracaoProduto
     * @returns valida os dados de alteracao do produto
     */
    function validaAlteracaoProduto() {

        var vr_idtxfixa = 0;
        var vr_idacumul = 0;
        var vr_indplano = 0;

        $('input[id="idtxfixa"]').each(function() {
            if ($(this).is(':checked')) {
                vr_idtxfixa = $(this).val();
            }
        });
        $('input[id="idacumul"]').each(function() {
            if ($(this).is(':checked')) {
                vr_idacumul = $(this).val();
            }
        });
        $('input[id="indplano"]').each(function() {
            if ($(this).is(':checked')) {
                vr_indplano = $(this).val();
            }
        });   

        showMsgAguardo("Aguarde, processando dados...");

        if (validaCamposTela()) {
            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_produto.php",
                dataType: "json",
                async: false,
                data: {
                    flgopcao: 'V',
                    cdprodut: $("#nmprodus option:selected").val(),
                    nmprodut: cNmprodut.val(),
                    idsitpro: cIdsitpro.val(),
                    cddindex: cCddindex.val(),
                    idtippro: cIdtippro.val(),
                    idtxfixa: vr_idtxfixa,
                    idacumul: vr_idacumul,
                    indplano: vr_indplano
                },
                success: function(retorno) {
                    if (retorno.rows == 1) {
                        $.each(retorno.records, function(i, item) {
                            if (item.nome == 'N' && item.parametro == 'N') {
                                showConfirmacao('Confirma a altera&ccedil;&atilde;o do produto ' + cNmprodut.val() + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gravaDadosProduto();ocultaMsgAguardo();', 'ocultaMsgAguardo();', 'sim.gif', 'nao.gif');
                            } else {
                                if (item.nome == 'S') {
                                    showError("error", "O nome do produto informado j� est� cadastrado.", "Alerta - Ayllos", "$('#nmprodut', '#frmCab').focus();ocultaMsgAguardo();");
                                } else if (item.parametro == 'S') {
                                    showConfirmacao("J&aacute; existe produto cadastrado com os par&acirc;metros informados. Confirma a altera&ccedil;&atilde;o do produto " + cNmprodut.val() + "?", 'Confirma&ccedil;&atilde;o - Ayllos', 'gravaDadosProduto();ocultaMsgAguardo();', 'ocultaMsgAguardo();', 'sim.gif', 'nao.gif');
                                }
                            }
                        });
                    } else if (retorno.erro == 'S') {
                        showError("error", retorno.msg, "Alerta - Ayllos", "resetaForm('dadosProdutos');hideMsgAguardo();");
                    }
                }
            });
        }
    }

    /**
     * @opcao P - Produtos de Captacao
     * @name validaCamposTela
     * @returns Valida o preenchimento dos campos
     */
    function validaCamposTela()
    {
        if (cNmprodut.val() == '') {
            showError("error", "Preencha o nome do produto.", "Alerta - Ayllos", "$('#nmprodut', '#frmCab').focus();");
            return false;
        }
        if (cIdsitpro.val() == 0) {
            showError("error", "Selecione a situa&ccedil;&atilde;o.", "Alerta - Ayllos", "$('#idsitpro', '#frmCab').focus();");
            return false;
        }
        if (cCddindex.val() == 0) {
            showError("error", "Selecione o indexador.", "Alerta - Ayllos", "$('#cddindex', '#frmCab').focus();");
            return false;
        }
        if (cIdtippro.val() == 0) {
            showError("error", "Selecione o tipo.", "Alerta - Ayllos", "$('#idtippro', '#frmCab').focus();");
            return false;
        }
        if (cIdtxfixa.val() <= 0 || cIdtxfixa.val() == '' || cIdtxfixa.val() == null) {
            showError("error", "Selecione a taxa fixa.", "Alerta - Ayllos", "");
            return false;
        }
        if (cIdacumul.val() <= 0 || cIdacumul.val() == '' || cIdacumul.val() == null) {
            showError("error", "Selecione a cumulativa.", "Alerta - Ayllos", "$('#idacumul', '#frmCab').focus();");
            return false;
        }
        if (cIndplano.val() <= 0 || cIndplano.val() == '' || cIndplano.val() == null) {
            showError("error", "Informe se programada.", "Alerta - Ayllos", "$('#indplano', '#frmCab').focus();");
            return false;
        }

        return true;
    }


    /**
     * @opcao P - Produtos de Captacao
     * @name gravaDadosProduto
     * @returns grava os dados do produto
     */
    function gravaDadosProduto() {

        var vr_idtxfixa = 0;
        var vr_idacumul = 0;
        var vr_indplano = 0;

        $('input[id="idtxfixa"]').each(function() {
            if ($(this).is(':checked')) {
                vr_idtxfixa = $(this).val();
            }
        });
        $('input[id="idacumul"]').each(function() {
            if ($(this).is(':checked')) {
                vr_idacumul = $(this).val();
            }
        });
        $('input[id="indplano"]').each(function() {
            if ($(this).is(':checked')) {
                vr_indplano = $(this).val();
            }
        });   
    
        showMsgAguardo("Aguarde, processando dados...");

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_produto.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'I',
                cdprodut: $("#hdncdprodut").val(),
                nmprodut: cNmprodut.val(),
                idsitpro: cIdsitpro.val(),
                cddindex: cCddindex.val(),
                idtippro: cIdtippro.val(),
                idtxfixa: vr_idtxfixa,
                idacumul: vr_idacumul,
                indplano: vr_indplano
            },
            success: function(retorno) {
                if (retorno.erro == 'N') {
                    resetaForm('dadosProdutos');
                    ocultaMsgAguardo();
                } else {
                    showError("error", retorno.msg, "Alerta - Ayllos", "ocultaMsgAguardo();");
                }
            }
        });
    }

    /**
     * @opcao P - Produtos de Captacao
     * @name excluiProduto
     * @returns exclui os dados do produto
     */
    function excluiDadosProduto() {
        showMsgAguardo("Aguarde, processando dados...");
        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_produto.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'E',
                cdprodut: $("#nmprodus option:selected").val()
            },
            success: function(retorno) {
                if (retorno.rows == 1) {
                    showMsgAguardo("Aguarde, processando...");
                    $.each(retorno.records, function(i, item) {
                        if (retorno.erro == 'N' && item.msg == 'OK') {
                            $("#nmprodus option:selected").hide();
                            resetaForm('dadosProdutos');
                        }
                    });
                    ocultaMsgAguardo();
                } else if (retorno.erro == 'S') {
                    showError("error", retorno.msg, "Alerta - Ayllos", "ocultaMsgAguardo();");
                }
            }
        });
    }

</script>
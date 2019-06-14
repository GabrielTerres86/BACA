<?php
/* !
 * FONTE        : form_modalidade.php
 * CRIA��O      : Jean Michel         
 * DATA CRIA��O : 30/04/2014
 * OBJETIVO     : Formulario de modalidade da tela PCAPTA
 * --------------
 * ALTERA��ES   : 
 * --------------
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

setVarSession('nmrotina', 'MODALIDADE');

?>
<div id="modalidadesProdConsult">
    <fieldset>
        <legend>Modalidades do Produto</legend>
        <table>
            <tr>
                <td>
                    <label for="nmprodut" >Produto:</label>
                    <select name="nmprodut" id="nmprodut">
                        <option value="0">-- Selecione --</option>                    
                    </select>                        
                </td>
            </tr>
            <tr>
                <td>
                    <label for="cddindex">Indexador:</label>
                    <input type="text" name="cddindex" id="cddindex" value="" maxlength="20" />
                </td>
            </tr>
            <tr class="linhaBotoes">
                <td>
                    <a href="javascript:void(0);" class="botao" id="btVoltar" name="btVoltar" onclick="resetaForm('modalidadesProdConsult');">Voltar</a>
                    <a href="javascript:void(0);" class="botao" id="btProseg"  onclick="consultaModalidade(1, 30, 'C');">Prosseguir</a>
                    <input type="hidden" name="idtxfixa" class="idtxfixa" value="" />
                </td>
            </tr>
        </table>
        <div class="divRetorno"></div>         
    </fieldset>
    <table class="tableAcoes">
        <tr>
            <td>
                <a href="javascript:void(0);" class="botao" id="btVoltar"  onclick="fnVoltar();
                        return false;">Voltar</a>
                <a href="javascript:void(0);" class="botao" id="btConsul"  onclick="escolheOpcao('M', 'C');">Consultar</a>                
                <a href="javascript:void(0);" class="botao" id="btExclui"  onclick="escolheOpcao('M', 'E');">Excluir</a>
                <a href="javascript:void(0);" class="botao" id="btInclui"  onclick="escolheOpcao('M', 'I');">Inserir</a>
            </td>
        </tr>
    </table>
</div>

<div id="modalidadesProdIncluir" style="display:none;">
    <fieldset>
        <legend>Modalidades do Produto - Inserir</legend>
        <table>
            <tr>
                <td>
                    <label for="cdprodut" >Produto:</label>
                    <select name="cdprodut" id="cdprodut">
                        <option value="0">-- Selecione --</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="qtdiacar">Car&ecirc;ncia:</label>
                    <input type="text" name="qtdiacar" id="qtdiacar" value="" class="inteiro" maxlength="5"/>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="qtdiaprz">Prazo:</label>
                    <input type="text" name="qtdiaprz" id="qtdiaprz" value="" class="inteiro" maxlength="5" />
                </td>
            </tr>
            <tr>
                <td>
                    <label for="vlrfaixa">Valor Inicial da Faixa:</label>
                    <input type="text" name="vlrfaixa" id="vlrfaixa" class="moeda" value="" />
                </td>
            </tr>
            <tr>
                <td>
                    <label for="vlperren">% Rentabilidade:</label>
                    <input type="text" name="vlperren" id="vlperren" class="porcento_8" value="" />
                </td>
            </tr>
            <tr>
                <td>
                    <label for="vltxfixa">% Taxa Fixa:</label>
                    <input type="text" name="vltxfixa" id="vltxfixa" class="porcento_8" value="" />
                </td>
            </tr>
            <tr class="linhaBotoes">
                <td>
                    <a href="javascript:void(0);" class="botao" id="btVoltar" name="btVoltar" onclick="resetaForm('modalidadesProdIncluir');">Voltar</a>
                    <a href="javascript:void(0);" class="botao" id="btProseg"  onclick="validaInsercaoModalidade();">Prosseguir</a>
                    <input type="hidden" value="0" id="hdnTxFixa" name="hdnTxFixa" />
                </td>
            </tr>
        </table>			
    </fieldset>
    <table class="tableAcoes">
        <tr>
            <td>
                <a href="javascript:void(0);" class="botao" id="btVoltar"  onclick="fnVoltar();
                        return false;">Voltar</a>
                <a href="javascript:void(0);" class="botao" id="btConsul"  onclick="escolheOpcao('M', 'C');">Consultar</a>                
                <a href="javascript:void(0);" class="botao" id="btExclui"  onclick="escolheOpcao('M', 'E');">Excluir</a>
                <a href="javascript:void(0);" class="botao" id="btInclui"  onclick="escolheOpcao('M', 'I');">Incluir</a>
            </td>
        </tr>
    </table>	
</div>

<div id="modalidadesProdExcluir" style="display:none;">
    <fieldset>
        <legend>Modalidades do Produto - Excluir</legend>
        <table>
            <tr>
                <td>
                    <label for="nmprodut">Produto:</label>
                    <select name="nmprodut" id="nmprodut">
                        <option value="0">-- Selecione --</option>                          
                    </select>
                </td>
            </tr>
            <tr>
                <td>
                    <label for="cddindex">Indexador:</label>
                    <input type="text" name="cddindex" id="cddindex" />
                </td>
            </tr>
            <tr class="linhaBotoes">
                <td>
                    <a href="javascript:void(0);" class="botao" id="btVoltar" name="btVoltar" onclick="resetaForm('modalidadesProdExcluir');">Voltar</a>
                    <a href="javascript:void(0);" class="botao" id="btProseg"  onclick="consultaModalidade(1, 30, 'E');">Prosseguir</a>
                    <input type="hidden" name="idtxfixa" class="idtxfixa" value="" />                    
                    <input type="hidden" name="hdnCodModalidade" id="hdnCodModalidade" value="" />                    
                </td>
            </tr>
        </table>    
        <div class="divRetorno"></div>        
    </fieldset>
    <table class="tableAcoes">
        <tr>
            <td>
                <a href="javascript:void(0);" class="botao" id="btVoltar"  onclick="fnVoltar();
                        return false;">Voltar</a>
                <a href="javascript:void(0);" class="botao" id="btConsul"  onclick="escolheOpcao('M', 'C');">Consultar</a>                
                <a href="javascript:void(0);" class="botao" id="btExclui"  onclick="escolheOpcao('M', 'E');">Excluir</a>
                <a href="javascript:void(0);" class="botao" id="btInclui"  onclick="escolheOpcao('M', 'I');">Inserir</a>
            </td>
        </tr>
    </table>	
</div>
<input type="hidden" id="stropcao" value="" />
<input type="hidden" id="hdnProdSel" value="0" />
<style type="text/css">

    #nmprodut, #cddindex, #cdprodut {
        width: 180px !important;
    }

    #pcapta fieldset table {
        margin-left: 70px;
    }

    #btCancel {
        margin-left: 120px;
    }

    fieldset table {
        margin-left: 25px;
    }
    #hdncdprodut {
        display: none;
    }
    table.tituloRegistros {
        margin-left: 0px !important;
    }
    #divPesquisaRodape table {
        margin-left: 0px !important;
    }
    tr.linhaBotoes #btVoltar {
        margin-left:120px;
    }  
    table.tableAcoes {
        margin-left:150px;
    }

    table tr.linhaBotoes {
        width: 360px;
        display: none;
    }

</style>
<script type="text/javascript">

    $(function() {

        $('#nmprodut', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                consultaIndexadorProduto($(this));
            }
        });

        $('#nmprodut', '#frmCab').unbind('click').bind('click', function() {
            consultaIndexadorProduto($(this));
        });

        $('#modalidadesProdIncluir #cdprodut').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                consultaTaxaProduto($(this));
            }
        });

        $("#modalidadesProdIncluir #cdprodut").unbind('click').bind('click', function() {
            //habilita os campos de rentabilidade e taxa fixa
            consultaTaxaProduto($(this));
        });

        $('#qtdiacar', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#qtdiaprz', '#frmCab').focus();
                return false;
            }
        });

        $('#qtdiaprz', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#vlrfaixa', '#frmCab').focus();
                return false;
            }
        });

        $('#vlrfaixa', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#vltxfixa', '#frmCab').focus();
                $('#vlperren', '#frmCab').focus();
                return false;
            }
        });

        $('#vltxfixa', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#btProseg', '#frmCab').focus();
                return false;
            }
        });

        $('#vlperren', '#frmCab').unbind('keypress').bind('keypress', function(e) {
            if (e.keyCode == 9 || e.keyCode == 13) {
                $('#btProseg', '#frmCab').focus();
                return false;
            }
        });

    });



    /**
     * @opcao M - Modalidades dos Produtos
     * @name consultaTaxaProduto
     * @returns retorna taxa fixa (S|N)
     */
    function consultaTaxaProduto(obj) {

        if ($(obj).val() > 0) {

            if ($("#hdnProdSel").val() != $(obj).val()) {

                $(obj).attr('disabled', true);
                showMsgAguardo("Aguarde, carregando dados...");

                $.ajax({
                    type: "POST",
                    url: UrlSite + "telas/pcapta/ajax_modalidade.php",
                    dataType: "json",
                    async: false,
                    data: {
                        flgopcao: 'C',
                        cdprodut: $(obj).val()
                    },
                    success: function(data) {
                        if (data.rows == 1) {
                            $.each(data.records, function(i, item) {
                                $("#hdnTxFixa").val(item.idtxfixa);
                                if (item.idtxfixa == 1) {
                                    cVlperren.hide();
                                    rVlperren.hide();
                                    cVltxfixa.removeAttr('disabled');
                                    cVltxfixa.show();
                                    rVltxfixa.show();
                                } else if (item.idtxfixa == 2) {
                                    cVlperren.removeAttr('disabled');
                                    cVlperren.show();
                                    rVlperren.show();
                                    cVltxfixa.hide();
                                    rVltxfixa.hide();
                                }
                            });
                        }
                    }
                });
                ocultaMsgAguardo();
                $('#qtdiacar', '#frmCab').focus();
            }
        }
        $("#hdnProdSel").val($('#nmprodut').val());
    }
    /**
     * @opcao M - Modalidades dos Produtos
     * @name consultaIndexadorProduto
     * @returns retorna o indexador
     */
    function consultaIndexadorProduto(obj) {

        if ($(obj).val() > 0) {

            if ($("#hdnProdSel").val() != $(obj).val()) {
                $.ajax({
                    type: "POST",
                    url: UrlSite + "telas/pcapta/ajax_modalidade.php",
                    dataType: "json",
                    async: false,
                    data: {
                        flgopcao: 'C',
                        cdprodut: $(obj).val()
                    },
                    success: function(data) {
                        if (data.rows == 1) {
                            $.each(data.records, function(i, item) {
                                $(obj).parent().parent().next().find("#cddindex").val(item.nmdindex);
                                $(".idtxfixa").val(item.idtxfixa);
                            });
                        }
                    }
                });
                ocultaMsgAguardo();
                $('#btProseg', '#frmCab').focus();
            }
            $("#hdnProdSel").val($(obj).val());
        }
    }

    function validaInsercaoModalidade()
    {
        if ($("#cdprodut").val() <= 0 || $("#cdprodut").val() == '' || $("#cdprodut").val() == null) {
            showError("error", "Selecione o produto.", "Alerta - Ayllos", "$('#cdprodut', '#frmCab').focus();");
            return false;
        }

        if ($.trim($("#qtdiacar").val()) == '' || $("#qtdiacar").val() == null) {
            showError("error", "Preencha a car�ncia.", "Alerta - Ayllos", "$('#qtdiacar', '#frmCab').focus();");
            return false;
        }

        if ($.trim($("#qtdiaprz").val()) == '' || $("#qtdiaprz").val() == null) {
            showError("error", "Preencha o prazo.", "Alerta - Ayllos", "$('#qtdiaprz', '#frmCab').focus();");
            return false;
        }

        if ($.trim($("#vlrfaixa").val()) == '' || $("#vlrfaixa").val() == null) {
            showError("error", "Preencha o valor inicial da faixa.", "Alerta - Ayllos", "$('#vlrfaixa', '#frmCab').focus();");
            return false;
        }

        if ($("#hdnTxFixa").val() == 2 && ($.trim($("#vlperren").val()) == '' || $("#vlperren").val() == null)) {
            showError("error", "Preencha o percentual de rentabilidade.", "Alerta - Ayllos", "$('#vlperren', '#frmCab').focus();");
            return false;
        }

        if ($("#hdnTxFixa").val() == 1 && ($.trim($("#vltxfixa").val()) == '' || $("#vltxfixa").val() == null)) {
            showError("error", "Preencha o percentual da taxa fixa.", "Alerta - Ayllos", "$('#vltxfixa', '#frmCab').focus();");
            return false;
        }

        //showMsgAguardo("Aguarde, validando dados...");

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_modalidade.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'V',
                cdprodut: $("#cdprodut").val(),
                qtdiacar: $("#qtdiacar").val(),
                qtdiaprz: $("#qtdiaprz").val(),
                vlrfaixa: $("#vlrfaixa").val(),
                vlperren: $("#vlperren").val(),
                vltxfixa: $("#vltxfixa").val()
            },
            success: function(data) {
                if (data.rows == 1) {
                    //ocultaMsgAguardo();

                    $.each(data.records, function(i, retorno) {
                        if (retorno.produto == 'N') {
                            showError("error", 'Produto inv�lido', "Alerta - Ayllos", "$('#cdprodut', '#frmCab').focus();");
                            //return false;
                        } else if (retorno.modalidade == 'S') {
                            showError("error", 'Modalidade j� cadastrada.', "Alerta - Ayllos", "");
                            //return false;
                        } else if (retorno.carencia == 'S') {
                            showError("error", 'A car�ncia deve ser maior ou igual � 30 dias', "Alerta - Ayllos", "$('#qtdiacar', '#frmCab').focus();");
                            //return false;
                        } else if (retorno.prazo == 'S') {
                            showError("error", 'O prazo deve ser maior ou igual � car�ncia', "Alerta - Ayllos", "$('#qtdiaprz', '#frmCab').focus();");
                            //return false;
                        } else if (retorno.taxa_fixa == 'S' && retorno.taxa_zerada == 'S') {
                            showError("error", 'Informe o percentual de taxa fixa', "Alerta - Ayllos", "$('#vltxfixa', '#frmCab').focus();");
                            //return false;
                        } else if (retorno.taxa_fixa == 'N' && retorno.percentual_zerado == 'S') {
                            showError("error", 'Informe o percentual de rentabilidade', "Alerta - Ayllos", "$('#vlperren', '#frmCab').focus();");
                            //return false;
                        } else if (retorno.rentabilidade == 'S') {
                            showError("error", 'Existe modalidade cadastrada com valor menor ou igual e rentabilidade maior', "Alerta - Ayllos", "");
                            //return false;
                        } else {
                            showConfirmacao('Confirma inclus�o da modalidade para o produto ' + $("#cdprodut option:selected").text() + '?', 'Confirma&ccedil;&atilde;o - Ayllos', 'gravaModalidade()', '', 'sim.gif', 'nao.gif');
                        }
                    });
                }
            }
        });
        //ocultaMsgAguardo();

    }

    /**
     * @opcao M - Modalidades dos Produtos
     * @name validaExclusaoModalidade
     * @returns 
     */
    function validaExclusaoModalidade()
    {
        var codModalidade = '';

        $("#modalidadesProdExcluir .tituloRegistros td input.cdmodali").each(function() {

            if ( $(this).is(':checked') ) {
                codModalidade += (codModalidade == '') ? $(this).attr('id') : ',' + $(this).attr('id');
            }
        });
        if (codModalidade != '') {
            $("#hdnCodModalidade").val(codModalidade);
            showConfirmacao('Confirma a exclus&atilde;o das modalidades?', 'Confirma&ccedil;&atilde;o - Ayllos', 'excluiModalidade()', '', 'sim.gif', 'nao.gif');
        } else {
            showError("error", 'Nenhuma modalidade selecionada para exclus&atilde;o.', "Alerta - Ayllos", "");
        }

    }

    /**
     * @opcao M - Modalidades dos Produtos
     * @name excluiModalidade
     * @returns 
     */
    function excluiModalidade()
    {
        var cdModali = $("#hdnCodModalidade").val();

        if (cdModali != '') {
            showMsgAguardo("Aguarde, processando...");

            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_modalidade.php",
                dataType: "json",
                async: false,
                data: {
                    flgopcao: 'E',
                    cdmodali: cdModali
                },
                success: function(retorno) {
                    if (retorno.erro == 'N') {
                        var arrModali = cdModali.split(',');
                        for (var c = 0; c <= arrModali.length; c++) {
                            if (arrModali[c] != 'undefined') {
                                $("#frmTaxas .tabModalidade #" + arrModali[c]).hide();
                            }
                        }
                        
                        var nrLinhasVisiveis = $("#frmTaxas .tabModalidade table tbody tr:visible").length;
                        
                        //caso nao houver mais nenhum item a ser selecionado na tabela, voltar
                        if ( nrLinhasVisiveis == 0 ) {
                            resetaCampos();
                        } else {
                            //atualiza o total de registros no rodape da tabela
                            $("#nrRegistrosTabela").text('Exibindo 1 at&eacute; '+nrLinhasVisiveis+' de '+nrLinhasVisiveis);
                        }                        
                        
                        // limpa o campo hidden
                        $("#hdnCodModalidade").val('');
                    } else {
                        showError("error", retorno.msg, "Alerta - Ayllos", "");
                    }
                }
            });
            ocultaMsgAguardo();
        }
        $("#hdnCodModalidade").val('');
    }

    /**
     * @opcao M - Modalidades dos Produtos
     * @name gravaModalidade
     * @returns 
     */
    function gravaModalidade() {
        showMsgAguardo("Aguarde, processando...");

        $.ajax({
            type: "POST",
            url: UrlSite + "telas/pcapta/ajax_modalidade.php",
            dataType: "json",
            async: false,
            data: {
                flgopcao: 'I',
                cdprodut: $("#cdprodut").val(),
                qtdiacar: $("#qtdiacar").val(),
                qtdiaprz: $("#qtdiaprz").val(),
                vlrfaixa: $("#vlrfaixa").val(),
                vlperren: $("#vlperren").val(),
                vltxfixa: $("#vltxfixa").val()
            },
            success: function(retorno) {
                if (retorno.erro == 'N') {
                    resetaForm('modalidadesProdIncluir');
                    ocultaMsgAguardo();
                } else {
                    showError("error", retorno.msg, "Alerta - Ayllos", "$('#cdprodut', '#frmCab').focus();ocultaMsgAguardo();");
                }
            }
        });
    }


    /**
     * @opcao M - Modalidades dos Produtos
     * @name consultaModalidade
     * @param {integer} nriniseq numero inicial de sequencia
     * @param {integer} nrregist numero final de sequencia
     * @param {string} subopcao de cada opcao pai 
     * @returns tabela com as modalidades do produto
     */
    function consultaModalidade(nriniseq, nrregist, subopcao) {

        var produto = $("#hdnProdSel").val();

        var divPrincipal = (subopcao == 'C') ? '#modalidadesProdConsult .idtxfixa' : '#modalidadesProdExcluir .idtxfixa';
        
        if (produto > 0) {
            bloqueiaFundo($('#divTela'));
            showMsgAguardo("Aguarde, carregando dados...");

            $.ajax({
                type: "POST",
                url: UrlSite + "telas/pcapta/ajax_modalidade.php",
                async: false,
                data: {
                    flgopcao: 'CM',
                    subopcao: subopcao,
                    cdprodut: produto,
                    nriniseq: nriniseq,
                    nrregist: nrregist,
                    idtxfixa: $(divPrincipal).val(),
                    redirect: "script_ajax"
                },
                success: function(data) {
                    if (data.indexOf('showError("error"') == -1) {
                        $("tr.linhaBotoes").hide();

                        if (subopcao == 'C') {
                            $('#modalidadesProdConsult #nmprodut').attr('disabled', 'disabled');
                            $('#modalidadesProdConsult #cddindex').attr('disabled', 'disabled');

                            $('#modalidadesProdConsult .divRetorno').empty().html(data).show();
                            $('#modalidadesProdExcluir .divRetorno').empty();
                        } else if (subopcao == 'E') {
                            $('#modalidadesProdExcluir #nmprodut').attr('disabled', 'disabled');
                            $('#modalidadesProdExcluir #cddindex').attr('disabled', 'disabled');

                            $('#modalidadesProdConsult .divRetorno').empty();
                            $('#modalidadesProdExcluir .divRetorno').empty().html(data).show();
                        }
                        formataTabelaModalidade();
                        ocultaMsgAguardo();
                    } else {
                        eval(data);
                        ocultaMsgAguardo();
                    }
                }
            });
        } else {
            showError("error", 'Selecione um produto', "Alerta - Ayllos", "$('#cdprodut', '#frmCab').focus();");
        }
    }

    /**
     * @opcao M - Modalidades dos Produtos
     * @name formataTabelaModalidade
     * @returns tabela com dados formatada
     */
    function formataTabelaModalidade() {

        // Tabela
        $('.tabModalidade').css({'display': 'block'});
        $('#divConsulta').css({'display': 'block'});

        var divRegistro = $('div.divRegistros', '.tabModalidade');
        var tabela = $('table', divRegistro);
        var linha = $('table > tbody > tr', divRegistro);

        $('.tabModalidade').css({'margin-top': '5px'});
        divRegistro.css({'height': '150px', 'width': '590px', 'padding-bottom': '2px'});

        var ordemInicial = new Array();

        var arrayAlinha = new Array();
        arrayAlinha[0] = 'left';
        arrayAlinha[1] = 'left';
        arrayAlinha[2] = 'left';
        arrayAlinha[3] = 'left';

        var arrayLargura = new Array();

        if ($("#modalidadesProdExcluir").css('display') == 'block') {
            arrayLargura[0] = '30px';
            arrayLargura[1] = '80px';
            arrayLargura[2] = '80px';
            arrayLargura[3] = '170px';
            //arrayLargura[4] = '170px';

            arrayAlinha[4] = 'left';
        } else {
            arrayLargura[0] = '108px';
            arrayLargura[1] = '100px';
            arrayLargura[2] = '160px';
            //arrayLargura[3] = '161px';
        }

        var metodoTabela = 'verDetalhe(this)';

        tabela.formataTabela(ordemInicial, arrayLargura, arrayAlinha, metodoTabela);
        ocultaMsgAguardo();

        //valida acao igual a excluir
        if ($("#modalidadesProdExcluir").css('display') == 'block') {        
            //remove ordenacao ao clicar no checkbox
            $("th:eq(0)", tabela).removeClass();
            $("th:eq(0)", tabela).unbind('click');
        }
        
        return false;
    }


    function carregaComboProdutos(acao)
    {
        var htmlOpcoes = '<option value="0">-- Selecione --</option>';

        var div = '';
        
        if ( acao == 'I' ) {
            div = '#modalidadesProdIncluir #cdprodut';
            acao = 'A';
        } else if ( acao == 'E' ) {
            div = '#modalidadesProdExcluir #nmprodut';
            acao = 'A';
        } else if ( acao == 'C' ) {
            div = '#modalidadesProdConsult #nmprodut';
        }

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

        $(div).empty().append(htmlOpcoes);
        ocultaMsgAguardo();
    }


</script>